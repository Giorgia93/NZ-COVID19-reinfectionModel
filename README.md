Branching process reinfection model to simulate COVID19 outbreak in New Zealand.
Coded in MATLAB2019b.

To run:
1. Run goOmiReinf.m


Main files:

- getParOmiWane.m    Most model parameters are defined here. 
- goOmiReinf.m       Main run file. Parameters subject to change for sensitivity analyses are defined here
- runSimWaning.m     Main loop of the branching process model

The main files call on spreadsheets in the "data" folder and on Matlab dependencies in the "dependencies folder".
Running goOmiReinf.m will produce timeseries in the "timeseries" folder and subfolders, a summary spreadsheet in the "summary" folder, and plots.
