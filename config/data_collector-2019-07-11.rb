require "json"

class Cfme::CloudServices::DataCollector
  def self.collect(target)
    new(target).collect
  end

  attr_reader :target

  def initialize(target)
    @target = target
  end

  def collect
    post_payload(process(fetch_manifest))
  end

  private

  def fetch_manifest
    JSON.parse(raw_manifest)
  end

  def raw_manifest
    # TODO: Download the manifest from the cloud for this CF version...for now just hardcode
    #
    # TODO: Modeling
    #   - Should we allow collection of non-model information, such as replication,
    #     pg_* tables or filesystem level things?
    common = {
      "id"                  => nil,
      "name"                => nil,
      "type"                => nil,
      "guid"                => nil,
      "uid_ems"             => nil,
      "api_version"         => nil,
      "emstype_description" => nil,
      "hostname"            => nil,
      "ems_licenses"        => {
        "id"              => nil,
        "ems_ref"         => nil,
        "name"            => nil,
        "license_key"     => nil,
        "license_edition" => nil,
        "total_licenses"  => nil,
        "used_licenses"   => nil,
      },
      "ems_extensions"      => {
        "id"      => nil,
        "ems_ref" => nil,
        "key"     => nil,
        "company" => nil,
        "label"   => nil,
        "version" => nil,
      },
      "ems_clusters"        => {
        "id"                  => nil,
        "name"                => nil,
        "type"                => nil,
        "ems_ref"             => nil,
        "v_parent_datacenter" => nil,
      },
      "hosts" => {
        "id"                   => nil,
        "ems_ref"              => nil,
        "name"                 => nil,
        "hostname"             => nil,
        "type"                 => nil,
        "cpu_total_cores"      => nil,
        "cpu_cores_per_socket" => nil,
        "ems_cluster_id"       => nil,
        "switches"             => {
          "id"      => nil,
          "name"    => nil,
          "uid_ems" => nil,
          "type"    => nil,
        },
        "storages"             => {
          "id"                 => nil,
          "name"               => nil,
          "ems_ref"            => nil,
          "store_type"         => nil,
          "multiplehostaccess" => nil,
        },
        "vms"                 => {
          "id"                => nil,
          "name"              => nil,
          "type"              => nil,
          "ems_ref"           => nil,
          "archived"          => nil,
          "orphaned"          => nil,
          "retired"           => nil,
          "num_cpu"           => nil,
          "has_rdm_disk"      => nil,
          "host_id"           => nil,
          "power_state"       => nil,
          "ipaddresses"       => nil,
          "hostnames"         => nil,
          "ram_size_in_bytes" => nil,
          "v_datastore_path"  => nil,
          "operating_system"  => {
            "product_type" => nil,
            "product_name" => nil,
            "distribution" => nil,
          },
          "hardware"             => {
            "id"                 => nil,
            "guest_os_full_name" => nil,
            "disks" => {
              "id"           => nil,
              "device_name"  => nil,
              "device_type"  => nil,
              "disk_type"    => nil,
              "filename"     => nil,
              "free_space"   => nil,
              "mode"         => nil,
              "size"         => nil,
              "size_on_disk" => nil,
            },
            "nics" => {
              "id"          => nil,
              "device_name" => nil,
              "device_type" => nil,
              "address"     => nil,
              "model"       => nil,
              "uid_ems"     => nil,
              "network"    => {
                "id"        => nil,
                "ipaddress" => nil,
                "hostname"  => nil,
              }
            }
          },
          "files" => {
            "id"       => nil,
            "name"     => nil,
            "contents" => nil,
          },
          "system_services" => {
            "id"       => nil,
            "name"     => nil,
            "typename" => nil,
          }
        }
      }
    }

    {
      "cfme_version" => cfme_version,
      "manifest" => {
        "core" => {
          "MiqDatabase" => {
            "id"                 => nil,
            "guid"               => nil,
            "region_number"      => nil,
            "region_description" => nil,
          },
          "Zone" => {
            "id"   => nil,
            "name" => nil
          }
        },
        "ManageIQ::Providers::OpenStack::CloudManager" => common.clone,
        "ManageIQ::Providers::Redhat::InfraManager"    => common.clone,
        "ManageIQ::Providers::Vmware::InfraManager"    => common.clone,
      }
    }.to_json
  end

  def process(manifest)
    case target
    when "core"
      process_core(manifest)
    when ExtManagementSystem
      process_provider(manifest)
    else
      raise "Unknown target: #{target.inspect}"
    end
  end

  def process_core(manifest)
    manifest = manifest.fetch_path("manifest", "core")
    return if manifest.blank?

    manifest.each_with_object({}) do |(model, model_manifest), payload|
      relation = scope_with_includes(manifest, model.constantize)
      content  = relation.map { |t| extract_data(t, model_manifest) }
      payload.store_path("core", model, content)
    end
  end

  def process_provider(manifest)
    manifest = manifest.fetch_path("manifest", target.class.name)
    return if manifest.blank?

    object  = scope_with_includes(manifest, target.class).find_by(:id => target.id)
    content = extract_data(object, manifest)
    {target.class.name => content}
  end

  def scope_with_includes(manifest, klass)
    klass.includes(includes_for(manifest, klass))
  end

  def includes_for(manifest, klass)
    manifest.each_with_object([]) do |(key, sub_manifest), includes|
      if klass.virtual_attribute?(key)
        includes << key
      elsif (relation = klass.reflections[key] || klass.virtual_reflection(key))
        includes << {key => includes_for(sub_manifest, relation.klass)}
      end
    end
  end

  def extract_data(target, manifest)
    return unless manifest

    manifest.each_with_object({}) do |(key, sub_manifest), payload|
      attr_or_rel = target.public_send(key)

      content =
        if attr_or_rel.kind_of?(ActiveRecord::Relation)
          attr_or_rel.map { |o| extract_data(o, sub_manifest) }
        elsif attr_or_rel.kind_of?(ActiveRecord::Base)
          extract_data(attr_or_rel, sub_manifest)
        else
          attr_or_rel
        end

      payload.store_path(key, content)
    end
  end

  def post_payload(payload)
    # TODO: Post the payload to the cloud...for now just write to log and STDOUT
    msg = "Collected the following payload:\n#{JSON.pretty_generate(payload)}"
    $log.info msg
    puts msg
  end

  def cfme_version
    Vmdb::Appliance.VERSION
  end
end
