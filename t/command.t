#!/usr/bin/env perl
use strict;
use warnings;
use Test::More;
use HiveJSO;
use JSON::MaybeXS;

{
  my $json = '{"unit":"jackson","command":"data"}';

  my $obj = HiveJSO->new_via_json($json);

  isa_ok($obj,'HiveJSO','object');
  is($obj->unit,"jackson",'Proper Unit');
  ok($obj->has_command,'Has an command attribute');
  is($obj->command,"data",'Has correct command');
  is($obj->original_json,'{"unit":"jackson","command":"data"}','correct original_json');
  is($obj->command_cmd,"data",'Has correct command cmd');
  ok(!$obj->has_command_args,'Has no command args');
  ok(!$obj->has_timestamp,'has no timestamp');
  ok(!$obj->has_product,'has no product');
  ok(!$obj->has_error_code,'has no error_code');
}

{
  my $json = '{"unit":"jackson","command":["data",2,3]}';

  my $obj = HiveJSO->new_via_json($json);

  isa_ok($obj,'HiveJSO','object');
  is($obj->unit,"jackson",'Proper Unit');
  ok($obj->has_command,'Has an command attribute');
  is_deeply($obj->command,["data",2,3],'Has correct command');
  is($obj->original_json,'{"unit":"jackson","command":["data",2,3]}','correct original_json');
  is($obj->command_cmd,"data",'Has correct command cmd');
  ok($obj->has_command_args,'Has command args');
  is_deeply([$obj->command_args],[2,3],'Has correct command args');
  is_deeply($obj->command_args_ref,[2,3],'Has correct command args ref');
  ok(!$obj->has_timestamp,'has no timestamp');
  ok(!$obj->has_product,'has no product');
  ok(!$obj->has_error_code,'has no error_code');
}

done_testing;
