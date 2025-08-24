# Sports KPI Simulator

## How to run (students)

### macOS
1. Unzip `sim_data_app-macOS.zip`.
2. Right-click `sim_data_app.app` → **Open** → **Open** (first-run Gatekeeper).
3. Click **Generate**, then **CSV** or **JSON**, choose a folder, save.

### Windows
1. Unzip `sim_data_app-Windows.zip`.
2. Double-click `sim_data_app.exe`.
3. Click **Generate**, then **CSV** or **JSON**, choose a folder, save.

## Notes
- macOS may warn about unknown developer. Right-click → Open once.
- Windows may show SmartScreen; click **More info** → **Run anyway**.


## PARAMETERS 
| Parameter                         | Description                                                                                                                                                           |
| --------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Players**                       | The number of players to simulate. Example: `45` will generate 45 rows of player stats.                                                                               |
| **Seed**                          | Seed ensures reproducibility. Using the same seed with the same parameters will generate identical datasets every time. Changing the seed produces different random variations of the same scenario.                                                  |
| **Minutes min**                   | Minimum number of minutes a simulated player can play. Example: `70` means no player will have fewer than 70 minutes.                                                 |
| **Minutes max**                   | Maximum number of minutes a simulated player can play. Example: `90` means no player will exceed 90 minutes.                                                          |
| **Distance mean (km)**            | The average distance covered (in kilometers) by a player. Example: `10.0` means players will average \~10 km.                                                         |
| **Distance std (km)**             | Standard deviation (variation) of distance covered. A higher value produces more variability. Example: `1.5` means most players will fall in ±1.5 km around the mean. |
| **Sprints λ**                     | The expected number of sprints (per game) based on a Poisson distribution. Example: `20.0` means players average \~20 sprints.                                        |
| **Passes min**                    | Minimum number of passes attempted by a player.                                                                                                                       |
| **Passes max**                    | Maximum number of passes attempted by a player.                                                                                                                       |
| **Pass acc min (0–1)**            | Minimum pass accuracy (as a fraction between `0` and `1`). Example: `0.70` means at least 70% accuracy.                                                               |
| **Pass acc max (0–1)**            | Maximum pass accuracy (as a fraction between `0` and `1`). Example: `0.95` means at most 95% accuracy.                                                                |
| **File name (without extension)** | The base name of the exported dataset. Example: `simulated_players` → creates `simulated_players.csv` or `simulated_players.json`.                                    |
