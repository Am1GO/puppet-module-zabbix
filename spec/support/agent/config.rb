shared_context 'zabbix::agent::config' do
  let(:facts) { default_facts }

  it { should create_class('zabbix::agent::config') }
  it { should contain_class('zabbix::agent') }

  it 'manage zabbix-agent user\'s home directory' do
    should contain_file('/var/lib/zabbix').only_with({
      :ensure   => 'directory',
      :path     => '/var/lib/zabbix',
      :mode     => '0750',
      :owner    => 'zabbix',
      :group    => 'zabbix',
    })
  end

  it 'manage zabbix-agent\'s log directory' do
    should contain_file('/var/log/zabbix').only_with({
      :ensure   => 'directory',
      :path     => '/var/log/zabbix',
      :mode     => '0775',
      :owner    => 'root',
      :group    => 'zabbix',
    })
  end

  it 'manage zabbix-agent\'s pid directory' do
    should contain_file('/var/run/zabbix').only_with({
      :ensure   => 'directory',
      :path     => '/var/run/zabbix',
      :mode     => '0775',
      :owner    => 'root',
      :group    => 'zabbix',
    })
  end

  it 'should set zabbix_agentd.conf Include value' do
    should contain_file_line('zabbix_agentd.conf Include').with({
      :path  => '/etc/zabbix_agentd.conf',
      :line  => 'Include=/etc/zabbix_agentd.conf.d',
      :match => '^Include=.*',
    })
  end

  it 'should manage zabbix_agentd.conf' do
    should contain_file('/etc/zabbix_agentd.conf').only_with({
      :ensure => 'file',
      :path   => '/etc/zabbix_agentd.conf',
      :owner  => 'root',
      :group  => 'root',
      :mode   => '0644',
    })
  end

  it 'manage zabbix-agent conf.d directory' do
    should contain_file('/etc/zabbix_agentd.conf.d').only_with({
      :ensure   => 'directory',
      :path     => '/etc/zabbix_agentd.conf.d',
      :mode     => '0755',
      :owner    => 'root',
      :group    => 'root',
      :recurse  => 'true',
      :purge    => 'true',
    })
  end

  it 'should manage zabbix_agentd_general.conf' do
    should contain_file('zabbix_agentd_general.conf').only_with({
      :ensure   => 'file',
      :path     => '/etc/zabbix_agentd.conf.d/zabbix_agentd_general.conf',
      :owner    => 'root',
      :group    => 'root',
      :mode     => '0644',
      :content  => /.*/,
      :require  => 'File[/etc/zabbix_agentd.conf.d]',
    })
  end

  it 'File[zabbix_agentd_general.conf] should have valid contents' do
    verify_contents(catalogue, 'zabbix_agentd_general.conf', [
      'PidFile=/var/run/zabbix/zabbix_agentd.pid',
      'LogFile=/var/log/zabbix/zabbix_agentd.log',
      'LogFileSize=0',
      '# DebugLevel=3',
      '# SourceIP=',
      'EnableRemoteCommands=0',
      'LogRemoteCommands=0',
      'Server=127.0.0.1',
      'ListenPort=10050',
      'ListenIP=0.0.0.0',
      'StartAgents=3',
      'ServerActive=127.0.0.1',
      'Hostname=foo.example.com',
      '# HostnameItem=system.hostname',
      '# HostMetadata=',
      '# HostMetadataItem=',
      'RefreshActiveChecks=120',
      'BufferSend=5',
      'BufferSize=100',
      'MaxLinesPerSecond=100',
    ])
  end

  it 'should manage zabbix_agentd_advanced.conf' do
    should contain_file('zabbix_agentd_advanced.conf').only_with({
      :ensure   => 'file',
      :path     => '/etc/zabbix_agentd.conf.d/zabbix_agentd_advanced.conf',
      :owner    => 'root',
      :group    => 'root',
      :mode     => '0644',
      :content  => /.*/,
      :require  => 'File[/etc/zabbix_agentd.conf.d]',
    })
  end

  it 'File[zabbix_agentd_advanced.conf] should have valid contents' do
    verify_contents(catalogue, 'zabbix_agentd_advanced.conf', [
      '# Alias=',
      'Timeout=3',
      'AllowRoot=0',
    ])
  end

  it 'should manage zabbix_agentd_modules.conf' do
    should contain_file('zabbix_agentd_modules.conf').only_with({
      :ensure   => 'file',
      :path     => '/etc/zabbix_agentd.conf.d/zabbix_agentd_modules.conf',
      :owner    => 'root',
      :group    => 'root',
      :mode     => '0644',
      :content  => /.*/,
      :require  => 'File[/etc/zabbix_agentd.conf.d]',
    })
  end

  it 'File[zabbix_agentd_modules.conf] should have valid contents' do
    verify_contents(catalogue, 'zabbix_agentd_modules.conf', [
      '# LoadModulePath=${libdir}/modules',
      '# LoadModule=',
    ])
  end

  it 'should manage zabbix_agentd_user_parameters.conf' do
    should contain_file('zabbix_agentd_user_parameters.conf').only_with({
      :ensure   => 'file',
      :path     => '/etc/zabbix_agentd.conf.d/zabbix_agentd_user_parameters.conf',
      :owner    => 'root',
      :group    => 'root',
      :mode     => '0644',
      :content  => /.*/,
      :require  => 'File[/etc/zabbix_agentd.conf.d]',
    })
  end

  it 'File[zabbix_agentd_user_parameters.conf] should have valid contents' do
    verify_contents(catalogue, 'zabbix_agentd_user_parameters.conf', [
      'UnsafeUserParameters=0',
      '# UserParameter=',
    ])
  end

  it 'should manage File[/etc/logrotate.d/zabbix-agent]' do
    should contain_file('/etc/logrotate.d/zabbix-agent').with({
      :ensure  => 'file',
      :owner   => 'root',
      :group   => 'root',
      :mode    => '0444',
    })
  end

  it { should_not contain_logrotate__rule('zabbix-agent') }

  it 'File[/etc/logrotate.d/zabbix-agent] should have valid contents' do
    verify_contents(catalogue, '/etc/logrotate.d/zabbix-agent', [
      '/var/log/zabbix/zabbix_agentd.log {',
      '  compress',
      '  create 0664 zabbix zabbix',
      '  missingok',
      '  monthly',
      '  notifempty',
      '  su zabbix zabbix',
      '}',
    ])
  end

  context 'when use_logrotate_rule => true' do
    let(:params) {{ :use_logrotate_rule => true }}

    it 'should manage logrotate::rule[zabbix-agent]' do
      should contain_logrotate__rule('zabbix-agent').with({
        :path         => '/var/log/zabbix/zabbix_agentd.log',
        :missingok    => 'true',
        :rotate_every => 'monthly',
        :ifempty      => 'false',
        :compress     => 'true',
        :create       => 'true',
        :create_mode  => '0664',
        :create_owner => 'zabbix',
        :create_group => 'zabbix',
        :su           => 'true',
        :su_owner     => 'zabbix',
        :su_group     => 'zabbix',
      })
    end

    it 'File[/etc/logrotate.d/zabbix-agent] should have valid contents' do
      verify_contents(catalogue, '/etc/logrotate.d/zabbix-agent', [
        '/var/log/zabbix/zabbix_agentd.log {',
        '  compress',
        '  create 0664 zabbix zabbix',
        '  missingok',
        '  monthly',
        '  notifempty',
        '  su zabbix zabbix',
        '}',
      ])
    end
  end

end