# Obtaining manually a payload for Migration Analytics

* SSH into CloudForms vm
```
# ssh cf.example.com
```

* Move to the CloudForms rails app folder
```
# vmdb
```

* Obtain the `manifest.json` file with the configuration of the data extraction
```
# curl https://raw.githubusercontent.com/RedHatDemos/RHS-Migration_Analytics/master/config/manifest.json >/dev/null > manifest.json
```

* Enter the rails console
```
# rails c
```

* Call the extraction method and save it to a file
```
payload = Cfme::CloudServices::DataCollector.collect(JSON.parse(File.read("manifest.json")), ManageIQ::Providers::Vmware::InfraManager.first)
Cfme::CloudServices::DataPackager.package(payload)
```
