# == Class: zabbix::agent::config
#
class zabbix::agent::config {

  include ::zabbix::agent

  $sudo_ensure = $::zabbix::agent::sudo_ensure ? {
    'present' => 'file',
    'absent'  => 'absent',
  }

  File {
    owner => 'zabbix',
    group => 'zabbix',
  }

  file { '/var/lib/zabbix':
    ensure => 'directory',
    path   => $::zabbix::agent::user_home_dir,
    mode   => '0750',
  }

  file { '/var/lib/zabbix/bin':
    ensure => 'directory',
    path   => $::zabbix::agent::scripts_dir,
    mode   => '0750',
  }

  file { '/var/log/zabbix':
    ensure => 'directory',
    path   => $::zabbix::agent::log_dir,
    owner  => 'root',
    mode   => '0775',
  }

  file { '/var/run/zabbix':
    ensure => 'directory',
    path   => $::zabbix::agent::pid_dir,
    mode   => '0755',
  }

  file { '/etc/zabbix_agentd.conf':
    ensure  => 'file',
    path    => $::zabbix::agent::config_file,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template('zabbix/agent/zabbix_agentd.conf.erb'),
  }

  file { '/etc/zabbix_agentd.conf.d':
    ensure  => 'directory',
    path    => $::zabbix::agent::config_d_dir,
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    recurse => true,
    purge   => $::zabbix::agent::purge_config_d_dir,
  }

  if $::zabbix::agent::manage_logrotate {
    # Make using logrotate::rule optional
    # because the version that supports 'su' is
    # not yet in the Forge.
    if $::zabbix::agent::use_logrotate_rule {
      $logrotate_rule = {
        'zabbix-agent' => $::zabbix::agent::logrotate_params,
      }

      create_resources('logrotate::rule', $logrotate_rule)
    } else {
      file { '/etc/logrotate.d/zabbix-agent':
        ensure  => 'file',
        owner   => 'root',
        group   => 'root',
        mode    => '0444',
        content => template('zabbix/logrotate/zabbix-agent.erb'),
      }
    }
  }

  if $::zabbix::agent::manage_sudo {
    datacat { 'zabbix-agent-sudo':
      ensure   => $sudo_ensure,
      owner    => 'root',
      group    => 'root',
      mode     => '0440',
      path     => "/etc/sudoers.d/${::zabbix::agent::sudo_priority}_zabbix-agent",
      template => 'zabbix/agent/sudo.erb',
    }
  }

}
