#
# Copyright (C) 2015 eNovance SAS <licensing@enovance.com>
#
# Author: Emilien Macchi <emilien.macchi@enovance.com>
#
# Licensed under the Apache License, Version 2.0 (the "License"); you may
# not use this file except in compliance with the License. You may obtain
# a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
# License for the specific language governing permissions and limitations
# under the License.
#
# Class to serve gnocchi API with apache mod_wsgi in place of gnocchi-api service.
#
# Serving gnocchi API from apache is the recommended way to go for production
# because of limited performance for concurrent accesses when running eventlet.
#
# When using this class you should disable your gnocchi-api service.
#
# == Parameters
#
#   [*servername*]
#     The servername for the virtualhost.
#     Optional. Defaults to $::fqdn
#
#   [*port*]
#     The port.
#     Optional. Defaults to 8041
#
#   [*bind_host*]
#     The host/ip address Apache will listen on.
#     Optional. Defaults to undef (listen on all ip addresses).
#
#   [*path*]
#     The prefix for the endpoint.
#     Optional. Defaults to '/'
#
#   [*ssl*]
#     Use ssl ? (boolean)
#     Optional. Defaults to true
#
#   [*workers*]
#     Number of WSGI workers to spawn.
#     Optional. Defaults to $::os_workers
#
#   [*priority*]
#     (optional) The priority for the vhost.
#     Defaults to '10'
#
#   [*threads*]
#     (optional) The number of threads for the vhost.
#     Defaults to 1
#
#   [*wsgi_process_display_name*]
#     (optional) Name of the WSGI process display-name.
#     Defaults to undef
#
#   [*ssl_cert*]
#   [*ssl_key*]
#   [*ssl_chain*]
#   [*ssl_ca*]
#   [*ssl_crl_path*]
#   [*ssl_crl*]
#   [*ssl_certs_dir*]
#     apache::vhost ssl parameters.
#     Optional. Default to apache::vhost 'ssl_*' defaults.
#
# == Dependencies
#
#   requires Class['apache'] & Class['gnocchi']
#
# == Examples
#
#   include apache
#
#   class { 'gnocchi::wsgi::apache': }
#
class gnocchi::wsgi::apache (
  $servername                 = $::fqdn,
  $port                       = 8041,
  $bind_host                  = undef,
  $path                       = '/',
  $ssl                        = true,
  $workers                    = $::os_workers,
  $ssl_cert                   = undef,
  $ssl_key                    = undef,
  $ssl_chain                  = undef,
  $ssl_ca                     = undef,
  $ssl_crl_path               = undef,
  $ssl_crl                    = undef,
  $ssl_certs_dir              = undef,
  $wsgi_process_display_name  = undef,
  $threads                    = 1,
  $priority                   = '10',
) {

  include ::gnocchi::deps
  include ::gnocchi::params
  include ::apache
  include ::apache::mod::wsgi
  if $ssl {
    include ::apache::mod::ssl
  }

  ::openstacklib::wsgi::apache { 'gnocchi_wsgi':
    bind_host                 => $bind_host,
    bind_port                 => $port,
    group                     => 'gnocchi',
    path                      => $path,
    priority                  => $priority,
    servername                => $servername,
    ssl                       => $ssl,
    ssl_ca                    => $ssl_ca,
    ssl_cert                  => $ssl_cert,
    ssl_certs_dir             => $ssl_certs_dir,
    ssl_chain                 => $ssl_chain,
    ssl_crl                   => $ssl_crl,
    ssl_crl_path              => $ssl_crl_path,
    ssl_key                   => $ssl_key,
    threads                   => $threads,
    user                      => 'gnocchi',
    workers                   => $workers,
    wsgi_daemon_process       => 'gnocchi',
    wsgi_process_display_name => $wsgi_process_display_name,
    wsgi_process_group        => 'gnocchi',
    wsgi_script_dir           => $::gnocchi::params::gnocchi_wsgi_script_path,
    wsgi_script_file          => 'app',
    wsgi_script_source        => $::gnocchi::params::gnocchi_wsgi_script_source,
  }
}
