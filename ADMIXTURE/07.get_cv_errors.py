import re
import os

with open('main_runs.txt', 'r') as f:
    main_runs = [line.strip().split() for line in f.readlines()]

output = []
for entry in main_runs:
    rg, k, r = entry
    filename = f"admixture_ready.all_unrelated_for.{rg}.k{k}.r{r}.out"

    if os.path.exists(filename):
        with open(filename, 'r') as file:
            for line in file:
                if "CV error" in line:
                    match = re.search(r"CV error \(K=(\d+)\):\s+([\d.]+)", line)
                    if match:
                        k_value = match.group(1)
                        cv_error = match.group(2)
                        output.append(f"{k_value}\t{r}\t{cv_error}")
                    break

with open('cv_results.txt', 'w') as f:
    f.write("K\tRun\tCV Error\n")
    f.write("\n".join(output))
