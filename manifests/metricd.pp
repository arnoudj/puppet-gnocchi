# Installs & configure the gnocchi metricd service
#
# == Parameters
#
# [*enabled*]
#   (optional) Should the service be enabled.
#   Defaults to true
#
# [*package_ensure*]
#   (optional) ensure state for package.
#   Defaults to 'present'
#
# [*workers*]
#   (optional) the number of workers.
#   Defaults to $::os_workers
#
# [*manage_service*]
#   (optional) Whether the service should be managed by Puppet.
#   Defaults to true.
#
class gnocchi::metricd (
  $manage_service = true,
  $enabled        = true,
  $workers        = $::os_workers,
  $package_ensure = 'present',
) inherits gnocchi::params {

  include ::gnocchi::deps

  gnocchi_config {
    'metricd/workers': value => $workers;
  }

  package { 'gnocchi-metricd':
    ensure => $package_ensure,
    name   => $::gnocchi::params::metricd_package_name,
    tag    => ['openstack', 'gnocchi-package'],
  }

  if $manage_service {
    if $enabled {
      $service_ensure = 'running'
    } else {
      $service_ensure = 'stopped'
    }
  }

  service { 'gnocchi-metricd':
    ensure     => $service_ensure,
    name       => $::gnocchi::params::metricd_service_name,
    enable     => $enabled,
    hasstatus  => true,
    hasrestart => true,
    tag        => ['gnocchi-service', 'gnocchi-db-sync-service'],
  }

}
