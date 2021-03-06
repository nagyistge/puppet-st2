# == Class: st2::profile::server
#
#  Profile to install all server components for st2
#
# === Parameters
#
#  [*version*]                - Version of StackStorm to install
#  [*revision*]               - Revision of StackStorm to install
#  [*auth*]                   - Toggle Auth
#  [*workers*]                - Set the number of actionrunner processes to 
#                               start
#  [*st2api_listen_ip*]       - Listen IP for st2api process
#  [*st2api_listen_port*]     - Listen port for st2api process
#  [*st2auth_listen_ip*]      - Listen IP for st2auth process
#  [*st2auth_listen_port*]    - Listen port for st2auth process
#  [*syslog*]                 - Routes all log messages to syslog
#  [*syslog_host*]            - Syslog host.
#  [*syslog_protocol*]        - Syslog protocol.
#  [*syslog_port*]            - Syslog port.
#  [*syslog_facility*]        - Syslog facility.
#  [*ssh_key_location*]       - Location on filesystem of Admin SSH key for remote runner
#
# === Variables
#
#  [*_server_packages*] - Local scoped variable to store st2 server packages.
#                         Sources from st2::params
#  [*_conf_dir*]        - Local scoped variable config directory for st2.
#                         Sources from st2::params
#  [*_python_pack*]     - Local scoped variable directory where system python lives
#                         Sources from st2::params
#
# === Examples
#
#  include st2::profile::client
#

class st2::profile::server (
  $version                = $::st2::version,
  $auth                   = $::st2::auth,
  $workers                = $::st2::workers,
  $syslog                 = $::st2::syslog,
  $syslog_host            = $::st2::syslog_host,
  $syslog_port            = $::st2::syslog_port,
  $syslog_facility        = $::st2::syslog_facitily,
  $syslog_protocol        = $::st2::syslog_protocol,
  $st2api_listen_ip       = '0.0.0.0',
  $st2api_listen_port     = '9101',
  $st2auth_listen_ip      = '0.0.0.0',
  $st2auth_listen_port    = '9100',
  $ssh_key_location       = $::st2::ssh_key_location,
  $ng_init                = $::st2::ng_init,
) inherits st2 {
  include '::st2::notices'
  include '::st2::params'

  $_server_packages = $::st2::params::st2_server_packages
  $_conf_dir = $::st2::params::conf_dir
  $_init_provider = $::st2::params::init_type
  $_python_pack = $::st2::params::python_pack

  $_enable_auth = $auth ? {
    true    => 'True',
    default => 'False',
  }
  $_logger_config = $syslog ? {
    true    => 'syslog',
    default => 'logging',
  }

  package{ $_server_packages:
    ensure => $version,
    tag    => 'st2::server::packages',
  }

  file { '/etc/st2':
    ensure => directory
  }

  ini_setting { 'ssh_key_stanley':
    ensure  => present,
    path    => '/etc/st2/st2.conf',
    section => 'system_user',
    setting => 'ssh_key_file',
    value   => $ssh_key_location,
    tag     => 'st2::config',
  }

  ## ActionRunner settings
  ini_setting { 'actionrunner_logging':
    ensure  => present,
    path    => '/etc/st2/st2.conf',
    section => 'actionrunner',
    setting => 'logging',
    value   => "/etc/st2/${_logger_config}.actionrunner.conf",
    tag     => 'st2::config',
  }

  ## API Settings
  ini_setting { 'api_listen_ip':
    ensure  => present,
    path    => '/etc/st2/st2.conf',
    section => 'api',
    setting => 'host',
    value   => $st2api_listen_ip,
    tag     => 'st2::config',
  }
  ini_setting { 'api_listen_port':
    ensure  => present,
    path    => '/etc/st2/st2.conf',
    section => 'api',
    setting => 'port',
    value   => $st2api_listen_port,
    tag     => 'st2::config',
  }
  ini_setting { 'api_allow_origin':
    ensure  => 'present',
    path    => '/etc/st2/st2.conf',
    section => 'api',
    setting => 'allow_origin',
    value   => '*',
    tag     => 'st2::config',
  }
  ini_setting { 'api_logging':
    ensure  => present,
    path    => '/etc/st2/st2.conf',
    section => 'api',
    setting => 'logging',
    value   => "/etc/st2/${_logger_config}.api.conf",
    tag     => 'st2::config',
  }

  ## Authentication Settings
  ini_setting { 'auth':
    ensure  => present,
    path    => '/etc/st2/st2.conf',
    section => 'auth',
    setting => 'enable',
    value   => $_enable_auth,
    tag     => 'st2::config',
  }

  ini_setting { 'auth_listen_port':
    ensure  => present,
    path    => '/etc/st2/st2.conf',
    section => 'auth',
    setting => 'port',
    value   => $st2auth_listen_port,
    tag     => 'st2::config',
  }
  ini_setting { 'auth_listen_ip':
    ensure  => present,
    path    => '/etc/st2/st2.conf',
    section => 'auth',
    setting => 'host',
    value   => $st2auth_listen_ip,
    tag     => 'st2::config',
  }
  ini_setting { 'auth_logging':
    ensure  => present,
    path    => '/etc/st2/st2.conf',
    section => 'auth',
    setting => 'logging',
    value   => "/etc/st2/${_logger_config}.auth.conf",
    tag     => 'st2::config',
  }

  ## Notifier Settings
  ini_setting { 'notifier_logging':
    ensure  => present,
    path    => '/etc/st2/st2.conf',
    section => 'notifier',
    setting => 'logging',
    value   => "/etc/st2/${_logger_config}.notifier.conf",
    tag     => 'st2::config',
  }

  ## Resultstracker Settings
  ini_setting { 'resultstracker_logging':
    ensure  => present,
    path    => '/etc/st2/st2.conf',
    section => 'resultstracker',
    setting => 'logging',
    value   => "/etc/st2/${_logger_config}.resultstracker.conf",
    tag     => 'st2::config',
  }

  ## Rules Engine Settings
  ini_setting { 'rulesengine_logging':
    ensure  => present,
    path    => '/etc/st2/st2.conf',
    section => 'rulesengine',
    setting => 'logging',
    value   => "/etc/st2/${_logger_config}.rulesengine.conf",
    tag     => 'st2::config',
  }

  ## Garbage collector Settings
  ini_setting { 'garbagecollector_logging':
    ensure  => present,
    path    => '/etc/st2/st2.conf',
    section => 'garbagecollector',
    setting => 'logging',
    value   => "/etc/st2/${_logger_config}.garbagecollector.conf",
    tag     => 'st2::config',
  }

  ## Sensor container Settings
  ini_setting { 'sensorcontainer_logging':
    ensure  => present,
    path    => '/etc/st2/st2.conf',
    section => 'sensorcontainer',
    setting => 'logging',
    value   => "/etc/st2/${_logger_config}.sensorcontainer.conf",
    tag     => 'st2::config',
  }

  ## Syslog Settings
  ini_setting { 'syslog_host':
    ensure  => present,
    path    => '/etc/st2/st2.conf',
    section => 'syslog',
    setting => 'host',
    value   => $syslog_host,
    tag     => 'st2::config',
  }
  ini_setting { 'syslog_protocol':
    ensure  => present,
    path    => '/etc/st2/st2.conf',
    section => 'syslog',
    setting => 'protocol',
    value   => $syslog_protocol,
    tag     => 'st2::config',
  }
  ini_setting { 'syslog_port':
    ensure  => present,
    path    => '/etc/st2/st2.conf',
    section => 'syslog',
    setting => 'port',
    value   => $syslog_port,
    tag     => 'st2::config',
  }
  ini_setting { 'syslog_facility':
    ensure  => present,
    path    => '/etc/st2/st2.conf',
    section => 'syslog',
    setting => 'facility',
    value   => $syslog_facility,
    tag     => 'st2::config',
  }

  service { $::st2::params::services:
    ensure => 'running',
    enable => true,
    tag    => 'st2::service',
  }

  Package<| tag == 'st2::server::packages' |>
  -> Ini_setting<| tag == 'st2::config' |>
  -> Service<| tag == 'st2::service' |>

}
