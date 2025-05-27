import pulp
import pandas as pd
import numpy as np

# === Load calibration data generated previously ===
# Assumes you saved the calibration table to 'calibration.csv' via build_calibration.py
df = pd.read_csv("calibration.csv")
# Build dictionaries: energy cost c[(dev, t)], temp drop a[(dev, t)]
c = {(row['device'], row['run_time_s']): row['energy_kWh'] for _, row in df.iterrows()}
a = {(row['device'], row['run_time_s']): row['temp_drop_C'] for _, row in df.iterrows()}
devices = sorted(df['device'].unique())
times   = sorted(df['run_time_s'].unique())

def solve_lp(devices, times, c, a, Delta):
    # Define LP: minimize sum c[i,t] x[i,t]
    prob = pulp.LpProblem("CoolingCover", pulp.LpMinimize)
    # Vars x_{i,t} in [0,1]
    x = pulp.LpVariable.dicts("x", (devices, times), lowBound=0, upBound=1, cat='Continuous')
    # Objective
    prob += pulp.lpSum(c[(i,t)] * x[i][t] for i in devices for t in times)
    # Coverage constraint
    prob += pulp.lpSum(a[(i,t)] * x[i][t] for i in devices for t in times) >= Delta
    # At most one run per device
    for i in devices:
        prob += pulp.lpSum(x[i][t] for t in times) <= 1
    prob.solve(pulp.PULP_CBC_CMD(msg=0))
    return pulp.value(prob.objective)

def primal_dual(devices, times, c, a, Delta):
    # Greedy (primal-dual) covering: pick sets by min cost-per-drop until coverage
    covered = 0.0
    selected = []
    dual_y = 0.0
    # Keep track of items not yet chosen
    items = [(i, t) for i in devices for t in times if a[(i,t)] > 0]
    while covered < Delta and items:
        # Find item with minimum c/(a)
        best = min(items, key=lambda it: c[it] / a[it])
        ratio = c[best] / a[best]
        dual_y = max(dual_y, ratio)
        selected.append(best)
        covered += a[best]
        # Remove all other times for the same device to enforce one per device
        items = [it for it in items if it[0] != best[0]]
    P = sum(c[it] for it in selected)
    D = dual_y * Delta
    return P, D

def main():
    deltas = np.linspace(0.5, max(a.values())*len(devices), num=10)
    records = []
    for Delta in deltas:
        lp_val = solve_lp(devices, times, c, a, Delta)
        P, D   = primal_dual(devices, times, c, a, Delta)
        records.append({
            "ΔT target": Delta,
            "LP optimum": round(lp_val, 4),
            "Primal cost": round(P, 4),
            "Dual bound": round(D, 4),
            "Primal/Dual": round(P/D, 4),
            "Primal/LP":   round(P/lp_val, 4)
        })
    df_res = pd.DataFrame(records)

    print(df_res)

if __name__ == "__main__":
    main()