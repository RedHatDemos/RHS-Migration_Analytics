# Obtaining manually a payload for Migration Analytics

* SSH into CloudForms VM
```
# ssh cf.example.com
```
* Move to the CloudForms rails app folder
```
# vmdb
```
* Obtain the `manifest.json` file with the configuration of the data extraction
```
# curl https://raw.githubusercontent.com/RedHatDemos/RHS-Migration_Analytics/master/config/manifest.json 2>/dev/null > manifest.json
```
* Enter the rails console
```
# rails c
```
* Call the extraction method
```
irb(main):001:0> payload = Cfme::CloudServices::DataCollector.collect(JSON.parse(File.read("manifest.json")), ManageIQ::Providers::Vmware::InfraManager.first)
[Output removed]
```
* Save it to a file
```
irb(main):002:0> Cfme::CloudServices::DataPackager.package(payload)
=> #<Pathname:/tmp/cfme_inventory20190731-18262-s0i9fo.tar.gz>
```

* In a different terminal copy the file
```
# cp /tmp/cfme_inventory20190731-18262-s0i9fo.tar.gz /root/
```

* Now exit the rails console. (Note: The temporary file will be removed)
```
irb(main):003:0> quit
```
