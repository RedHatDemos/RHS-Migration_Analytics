== Payload Generator

Just as Thomas Patrick Keating forged amazing works of art so to does keating forge amazing json payload files for migration analytics demonstrations based on [Project Xavier](https://github.com/project-xavier).

Based on the work by James Labocki in the following repo `https://github.com/jameslabocki/keating.git`

to run it, execute the shell script with a required argument for the number of hosts to include in the payload

```
# ./keating.sh <number of hosts to create in payload>
```

Upload the .json payload to migration analytics in https://cloud.redhat.com/beta

If you want to see how workloads are detected in [Project Xavier](https://github.com/project-xavier) you can review the [Flags](https://github.com/project-xavier/xavier-analytics/blob/master/src/main/resources/org/jboss/xavier/analytics/rules/workload/inventory/Flags.drl) and [Workloads](https://github.com/project-xavier/xavier-analytics/blob/master/src/main/resources/org/jboss/xavier/analytics/rules/workload/inventory/Workloads.drl) rules files.


