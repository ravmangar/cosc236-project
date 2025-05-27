from OMPython import OMCSessionZMQ, ModelicaSystem
import numpy as np
import pandas as pd


times   = [600, 1200, 1800, 2400]
devices = [f"AC{k}" for k in range(1,6)]

omc = OMCSessionZMQ()

c = {}
a = {}

model_path="/home/ravindra/Documents/cosc236-project/"

mod=ModelicaSystem(model_path + "test.mo","test",["/home/ravindra/Documents/cosc236-project/Buildings-v9.1.1/Buildings 9.1.1/package.mo"])

mod.buildModel()

for k in range(1,6):
    dev = f"AC{k}"
    for t in times:
        params = [f"nAC={k}",
                  f"onTime{k}=0", f"offTime{k}={t}"]
        # turn all other ACs off
        for j in range(1, 6):
            if j != k:
                params += [f"onTime{j}=0", f"offTime{j}=0"]
        print(params)
        mod.setParameters(params)

        mod.setSimulationOptions([
            "startTime=0",
            "stopTime=3600",
            "tolerance=1e-6"
        ])

        res = mod.simulate()

        var_time = "time"
        var_temp = "tempSense.T"
        var_power = f"ac{k}.Q_flow"  # <<< notice this change

        solutions = mod.getSolutions([var_time, var_temp, var_power])
        time = np.array(solutions[0])
        temp = np.array(solutions[1])
        power = np.array(solutions[2])

        # 5) compute ΔT and energy
        deltaT = float(temp[0] - temp.min())
        E_J = np.trapz(power, time)
        c[(dev, t)] = abs(E_J) / 3.6e6
        a[(dev, t)] = deltaT
        print(f"{dev} @ {t}s → ΔT={deltaT:.3f}°C, E={c[(dev, t)]:.3f} kWh")


df_calib = pd.DataFrame([
    {"device":d, "run_time_s":t,
     "energy_kWh":round(c[(d,t)],4),
     "temp_drop_C":round(a[(d,t)],4)}
    for d in devices for t in times
])
print(df_calib)







