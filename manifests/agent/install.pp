# == Class: zabbix::agent::install
#
# Private class
#
class zabbix::agent::install {

  include ::zabbix::agent

  package { 'zabbix::agent':
    ensure  => $::zabbix::agent::package_ensure,
    name    => $::zabbix::agent::package_name_real
  }

}
