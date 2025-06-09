from OMPython import OMCSessionZMQ, ModelicaSystem
import numpy as np
import pandas as pd
from functools import lru_cache

# Setup
omc = OMCSessionZMQ()
model_path = "/home/ravindra/Documents/cosc236-project/"
model_file = model_path + "test.mo"
model_name = "test_fan"

# Load the model
mod=ModelicaSystem(model_path + "test_fan.mo","test_fan",["/home/ravindra/Documents/cosc236-project/Buildings-v9.1.1/Buildings 9.1.1/package.mo"])


# Build
mod.buildModel()

def simulate_acs(devices):
    # Extract all AC and DH names and runtimes
    acs = [(dev, t) for dev, t in devices if dev.startswith("AC")]
    dhs = [(dev, t) for dev, t in devices if dev.startswith("DH")]

    # Generate AC usage and timing parameters
    ac_params = [f"useAC{i}=false" for i in range(1, 9)]
    ac_timing = [f"AConTime{i}=0" for i in range(1, 9)] + [f"ACoffTime{i}=0" for i in range(1, 9)]

    for dev, t in acs:
        k = int(dev[2])
        ac_params[k - 1] = f"useAC{k}=true"
        ac_timing[k - 1] = f"AConTime{k}=0"
        ac_timing[k - 1 + 8] = f"ACoffTime{k}={t}"

    # Generate DH usage and timing parameters
    dh_params = [f"useDehum{i}=false" for i in range(1, 9)]
    dh_timing = [f"dehumOnTime{i}=0" for i in range(1, 9)] + [f"dehumOffTime{i}=0" for i in range(1, 9)]

    for dev, t in dhs:
        k = int(dev[2])
        dh_params[k - 1] = f"useDehum{k}=true"
        dh_timing[k - 1] = f"dehumOnTime{k}=0"
        dh_timing[k - 1 + 8] = f"dehumOffTime{k}={t}"

    # Combine all parameters
    param_list = ac_params + ac_timing + dh_params + dh_timing

    mod.setParameters(param_list)
    mod.setSimulationOptions([
        "startTime=0",
        "stopTime=3600",
        "tolerance=1e-6"
    ])

    print(f"Simulating devices: {devices}")
    mod.simulate()

    # Extract output variables
    var_list = ["time", "tempSense.T", "humSens.phi"]
    for dev, _ in acs:
        k = int(dev[2])
        var_list.append(f"ac{k}.Q_flow")
    for dev, _ in dhs:
        k = int(dev[2])
        var_list.append(f"powerDehum{k}.u")

    # Get solutions
    sols = mod.getSolutions(var_list)
    if sols is None:
        raise RuntimeError("Simulation failed or variables not found.")

    data = {var: np.array(s).flatten() for var, s in zip(var_list, sols)}

    time = data["time"]
    temp = data["tempSense.T"]
    hum = data["humSens.phi"]

    # Calculate ΔT and ΔHumidity
    deltaT = float(temp[0] - temp.min())
    deltaH = float(hum[0] - hum.min())

    # Calculate total energy in kWh
    E_J = 0
    for dev, _ in acs:
        k = int(dev[2])
        power = data[f"ac{k}.Q_flow"]
        E_J += np.trapz(np.abs(power), time)
    for dev, _ in dhs:
        k = int(dev[2])
        power = data[f"powerDehum{k}.u"]
        E_J += np.trapz(power, time)

    E_kWh = E_J / 3.6e6


    print(ac_params, ac_timing)
    print(dh_params, dh_timing)

    print(f"→ ΔT = {deltaT:.3f}°C, Δφ = {deltaH:.3f}, E = {E_kWh:.3f} kWh")
    return {
        "devices": devices,
        "temp_drop_C": round(deltaT, 4),
        "humidity_drop": round(deltaH, 4),
        "energy_kWh": round(E_kWh, 4)
    }



DEVICES_TIMES = [
    ('AC1', 100), ('AC1', 500), ('AC1', 1000),
    ('AC2', 100), ('AC2', 500), ('AC2', 1000),
	('AC3', 100), ('AC3', 500), ('AC3', 1000),
    ('AC4', 100), ('AC4', 500), ('AC4', 1000),
	('AC5', 100), ('AC5', 500), ('AC5', 1000),
    ('AC6', 100), ('AC6', 500), ('AC6', 1000),
	('AC7', 100), ('AC7', 500), ('AC7', 1000),
    ('AC8', 100), ('AC8', 500), ('AC8', 1000),
    ('DH1', 100), ('DH1', 500), ('DH1', 1000),
    ('DH2', 100), ('DH2', 500), ('DH2', 1000),
	('DH3', 100), ('DH3', 500), ('DH3', 1000),
    ('DH4', 100), ('DH4', 500), ('DH4', 1000),
	('DH5', 100), ('DH5', 500), ('DH5', 1000),
    ('DH6', 100), ('DH6', 500), ('DH6', 1000),
	('DH7', 100), ('DH7', 500), ('DH7', 1000),
    ('DH8', 100), ('DH8', 500), ('DH8', 1000)

]



@lru_cache(maxsize=None)
def get_cost(pair):
    try:
        result = simulate_acs([pair])
        return result["energy_kWh"]
    except Exception:
        return 0.0

@lru_cache(maxsize=None)
def get_temp_drop(pair):
    try:
        result = simulate_acs([pair])
        return result["temp_drop_C"]
    except Exception:
        return 0.0

@lru_cache(maxsize=None)
def get_humidity_drop(pair):
    try:
        result = simulate_acs([pair])
        return result["humidity_drop"]
    except Exception:
        return 0.0

# === SUBMODULAR TEMP-DROP FUNCTION (DIMINISHING RETURNS) ===
def temp_drop_submodular(S):
    """
    Return the total temperature drop from all chosen device/time pairs in S,
    accounting explicitly for diminishing returns of multiple devices.
    """

    # YOUR REALISTIC DIMINISHING RETURNS MODEL HERE
    total_drop = 0.0
    ac_pairs = [p for p in S if 'AC' in p[0]]
    fan_pairs = [p for p in S if 'Fan' in p[0]]

    # Example placeholder logic for diminishing returns:
    # Each extra device contributes half as much as the previous.
    ac_pairs.sort(key=lambda p: get_temp_drop(p), reverse=True)
    fan_pairs.sort(key=lambda p: get_temp_drop(p), reverse=True)

    decay_factor_ac = 1.0
    for p in ac_pairs:
        total_drop += get_temp_drop(p) * decay_factor_ac
        decay_factor_ac *= 0.5

    decay_factor_fan = 1.0
    for p in fan_pairs:
        total_drop += get_temp_drop(p) * decay_factor_fan
        decay_factor_fan *= 0.5

    return total_drop


def humidity_drop_submodular(S):
    total_drop = 0.0
    dh_pairs = [p for p in S if 'DH' in p[0]]
    ac_pairs = [p for p in S if 'AC' in p[0]]

    dh_pairs.sort(key=lambda p: get_humidity_drop(p), reverse=True)
    ac_pairs.sort(key=lambda p: get_humidity_drop(p), reverse=True)

    decay_dh = 1.0
    for p in dh_pairs:
        total_drop += get_humidity_drop(p) * decay_dh
        decay_dh *= 0.5

    decay_ac = 1.0
    for p in ac_pairs:
        total_drop += get_humidity_drop(p) * decay_ac
        decay_ac *= 0.5

    return total_drop

# === MARGINAL GAIN FUNCTION ===
def marginal_gain(C, p):
    return temp_drop_submodular(C | {p}) - temp_drop_submodular(C)

# === HARMONIC NUMBER ===
def harmonic_number(n):
    return sum(1 / i for i in range(1, n + 1)) if n >= 1 else 0

# === GREEDY DUAL-FITTING ALGORITHM ===
def GreedyDualChargingMulti(pairs, target_temp=None, target_humidity=None):
    def combined_drop(S):
        temp = temp_drop_submodular(S) if target_temp else 0
        hum = humidity_drop_submodular(S) if target_humidity else 0
        return temp, hum

    def still_needed(S):
        current_temp, current_hum = combined_drop(S)
        temp_remaining = max(target_temp - current_temp, 0) if target_temp else 0
        hum_remaining = max(target_humidity - current_hum, 0) if target_humidity else 0
        return temp_remaining, hum_remaining

    def gain(C, p):
        before_temp, before_hum = combined_drop(C)
        after_temp, after_hum = combined_drop(C | {p})
        temp_gain = after_temp - before_temp
        humidity_gain = after_hum - before_hum
        return temp_gain, humidity_gain

    # Feasibility check
    full_temp, full_hum = combined_drop(set(pairs))
    if target_temp and full_temp < target_temp:
        raise ValueError("Target temperature drop is infeasible.")
    if target_humidity and full_hum < target_humidity:
        raise ValueError("Target humidity drop is infeasible.")

    C = set()
    dual = {}

    beta = max(temp_drop_submodular({p}) if target_temp else 0 for p in pairs)
    H_beta = harmonic_number(int(beta)) if target_temp else 1

    while True:
        temp_needed, hum_needed = still_needed(C)
        if temp_needed <= 0 and hum_needed <= 0:
            break

        best_pair = None
        best_ratio = float('inf')

        for p in pairs:
            if p in C:
                continue

            temp_gain, humidity_gain = gain(C, p)
            if temp_gain <= 0 and humidity_gain <= 0:
                continue

            total_progress = 0
            if target_temp and temp_needed > 0:
                total_progress += temp_gain / temp_needed
            if target_humidity and hum_needed > 0:
                total_progress += humidity_gain / hum_needed

            ratio = get_cost(p) / total_progress
            if ratio < best_ratio:
                best_pair = p
                best_ratio = ratio

        if best_pair is None:
            raise RuntimeError("No remaining useful pairs. Cannot meet target.")

        key = frozenset(C)
        temp_gain, _ = gain(C, best_pair)
        dual_val = get_cost(best_pair) / (temp_gain if temp_gain > 0 else 1)
        dual[key] = dual_val / H_beta if target_temp else dual_val

        C.add(best_pair)

    schedule = prune_pairs(C)
    return schedule, dual, beta, H_beta


# === PRUNING FUNCTION ===
def prune_pairs(C):
    longest = {}
    for dev, t in C:
        if dev not in longest or t > longest[dev][1]:
            longest[dev] = (dev, t)
    return set(longest.values())

# === DRIVER CODE ===
if __name__ == "__main__":
    TARGET_TEMP_DROP = 12.0  # desired temperature drop
    TARGET_HUMIDITY_DROP = 0.5


    schedule, dual_y, beta, H_beta = GreedyDualChargingMulti(DEVICES_TIMES, target_temp=TARGET_TEMP_DROP,
                                                             target_humidity=TARGET_HUMIDITY_DROP)

    cost_schedule = sum(get_cost(p) for p in schedule)
    dual_value = 0.0
    for A, val in dual_y.items():
        temp_deficit = TARGET_TEMP_DROP - temp_drop_submodular(set(A)) if TARGET_TEMP_DROP else 0
        humidity_deficit = TARGET_HUMIDITY_DROP - humidity_drop_submodular(set(A)) if TARGET_HUMIDITY_DROP else 0
        dual_value += (temp_deficit + humidity_deficit) * val

    print("Chosen pruned schedule:")
    for dev, t in sorted(schedule):
        print(f"  Device: {dev}, Time: {t}")

    print(f"\nTotal Cost: {cost_schedule:.2f}")
    print(f"Dual Objective Value: {dual_value:.2f}")
    print(f"β: {beta}, H_β: {H_beta:.3f}")

    if dual_value > 0:
        print(f"Approximation Ratio (ALG / Dual): {cost_schedule / dual_value:.3f}")

