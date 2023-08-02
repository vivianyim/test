# Monte Carlo Monitors Development

Monte Carlo is a data observebility platform which we use for monitoring the quality of our production data. We use their "monitors-as-code" yaml format for defining custom monitors. This is the reference documentation:
https://docs.getmontecarlo.com/docs/monitors-as-code#monitor-configuration-reference

## Adding and Modifying Monitors

The monitor configuration is located in **"charts/data-monitors-charts/monitor-configurations"**. The monitors for each data source should be in a separate file. For example, all Gamlog monitors should be in a file called gamlog.yaml

To validate that the monitor configuration is valid locally, execute the following commands:

 1 - You need a running Kubernetes cluster - follow the steps to set up Hyak local development environment.

 2 - Refresh the aws credentials by running:
 ```
    saml2aws login --profile saml
 ```
 3 - Create Kind cluster, install dependencies, and execute the Data Monitors job with --dry-run option
 ```
    ./platform.sh deploy_data_monitors
 ```
 4 - Refresh the chart and execute the Data Monitors job with --dry-run option
 ```
    ./platform.sh update_data_monitors
 ```

This will trigger the "dps-platform-data-monitors-job" in the local kubernetes cluster. The job will do a dry run of the monitor configuraiton using the montecarlo cli tool. If the monitor configuration is invalid the job will fail.
A failed job will have a status Error for the dps-platform-data-monitors-job pod:
```
kubectl get pods -n dps
```
The job logs will show what errors were encountered during the validation if any.
To see the job logs, execute (replace the job name with the correct one):
```
kubectl logs -n dps dps-platform-data-monitors-job-xxxxx
```

Alternatively, you can use [K9S](https://k9scli.io/) tool to view the status of the job and the logs.

Note: The job will be deleted automatically after execution. To disable job deletion, set "dataMonitorsDeleteJobs" to "false" in charts/data-monitors-chart/values-files/values-local.yaml

## Deploying of Monitors to the Monte Carlo environment

### Validating the Data Monitors

Adding the following git tags for *dev* or *stage* env will trigger the Data Monitors with the "--dry-run" option. This means that the monitors will be validated but not actually applied to the MonteCarlo environment:

* `v0.0.1-dev-data-monitors.11` for Data Monitors to execute with "--dry-run" option in dev env.
* `v0.0.1-stage-data-monitors.11` for Data Monitors to execute with "--dry-run" option in stage env.

### Applying the Data Monitors
Adding the following git tag for the
*production* env will trigger the Data Monitors and apply them in MonteCarlo. This means that the monitors will be actually created or updated in the MonteCarlo environment:
* `v0.0.1-prod-data-monitors.11` for Data Monitors to be added/updated in the MonteCarlo env.

### Logs
To see the result of the Data Monitors job in Datadog, use
* service:dps-platform-data-monitors
* env:development/stage/production
* Example Datadog link:
https://app.datadoghq.com/logs?query=service%3Adps-platform-data-monitors%20env%3Adevelopment
