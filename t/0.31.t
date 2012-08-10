use strict;
use warnings;

use Test::More tests => 77;
use Data::Dumper;


use_ok 'Rex';
use_ok 'Rex::Config';
use_ok 'Rex::Group';
use_ok 'Rex::Task';
use_ok 'Rex::TaskList';
use_ok 'Rex::Commands';
use_ok 'Rex::Commands::Run';
use_ok 'Rex::Commands::Upload';

Rex->import(-feature => 0.31);
Rex::Commands->import();

user("root3");
password("pass3");
private_key("priv.key3");
public_key("pub.key3");


no warnings;
ok($Rex::TaskList::DEFAULT_AUTH == 0, "default auth off");
use warnings;


group("foo", "server1", "server2", "server3");
group("bar", "serv[01..10]");

my @servers = Rex::Group->get_group("foo");
ok($servers[0] eq "server1", "get_group");
ok($servers[2] eq "server3", "get_group");

@servers = Rex::Group->get_group("bar");
@servers = $servers[0]->get_servers;
ok($servers[0] eq "serv01", "get_group with evaluation");
ok($servers[5] eq "serv06", "get_group with evaluation");

task("authtest1", group => "foo", sub {});
task("authtest2", group => "bar", sub {});

auth(for => "bar", user => "jan", password => "foo");

my $task = Rex::TaskList->get_task("authtest1");

my @all_server = @{ $task->server };

for my $server (@all_server) {
   my $auth = $task->merge_auth($server);
   ok($auth->{user} eq "root3", "merge_auth - user");
   ok($auth->{password} eq "pass3", "merge_auth - pass");
   ok($auth->{public_key} eq "pub.key3", "merge_auth - pub");
   ok($auth->{private_key} eq "priv.key3", "merge_auth - priv");
}

$task = Rex::TaskList->get_task("authtest2");
@all_server = @{ $task->server };

for my $server (@all_server) {
   my $auth = $task->merge_auth($server);
   ok($auth->{user} eq "jan", "merge_auth - user");
   ok($auth->{password} eq "foo", "merge_auth - pass");
   ok($auth->{public_key} eq "pub.key3", "merge_auth - pub");
   ok($auth->{private_key} eq "priv.key3", "merge_auth - priv");
}

auth(for => "authtest1", user => "deploy", password => "baz", private_key => FALSE(), public_key => FALSE());

$task = Rex::TaskList->get_task("authtest1");
@all_server = @{ $task->server };

for my $server (@all_server) {
   my $auth = $task->merge_auth($server);
   ok($auth->{user} eq "deploy", "merge_auth - user");
   ok($auth->{password} eq "baz", "merge_auth - pass");
   ok($auth->{public_key} == FALSE(), "merge_auth - pub");
   ok($auth->{private_key} == FALSE(), "merge_auth - priv");
}

