#!/usr/bin/env perl
use strict;
use warnings;
use Test::More;
use HiveJSO;
use JSON::MaybeXS;

{
  my $json = '{"unit":"202481588441972/1","ok":1}';

  my $obj = HiveJSO->new_via_json($json);

  isa_ok($obj,'HiveJSO','object');
  is($obj->unit,"202481588441972/1",'Proper Unit');
  ok($obj->has_ok,'Has an ok attribute');
  is($obj->ok,1,'ok value is 1');
  is($obj->original_json,'{"unit":"202481588441972/1","ok":1}','correct original_json');
  ok(!$obj->has_timestamp,'has no timestamp');
  ok(!$obj->has_product,'has no product');
  ok(!$obj->has_error_code,'has no error_code');
}

{
  my $obj = HiveJSO->new({ unit => "202481588441972/1", ok => 1 });

  isa_ok($obj,'HiveJSO','object');
  is($obj->unit,"202481588441972/1",'Proper Unit');
  ok($obj->has_ok,'Has an ok attribute');
  is($obj->ok,1,'ok value is 1');
  ok(!$obj->has_original_json,'has not original json');
  ok(!$obj->has_timestamp,'has no timestamp');
  ok(!$obj->has_product,'has no product');
  ok(!$obj->has_error_code,'has no error_code');
  is_deeply(decode_json($obj->hivejso_short),{
    ok => 1,
    u => "202481588441972/1",
    c => 3953183359,
  },'Short HiveJSO is fine');
  is_deeply(decode_json($obj->hivejso),{
    ok => 1,
    unit => "202481588441972/1",
    checksum => 3367072037,
  },'HiveJSO is fine');
}

{
  my $json = '{"unit":"202481588441972/1"}';

  eval {
    HiveJSO->new_via_json($json);
  };

  like($@,qr/more attributes/,'Invalid HiveJSO with just one attribute');
}

{
  my $json = '{"unit":"202481588441972/1","unknown_attribute":1}';

  eval {
    HiveJSO->new_via_json($json);
  };

  like($@,qr/not a valid HiveJSO attribute/,'unknown_attribute is invalid HiveJSO attribute');
}

{
  my $json = '{"unit":"202481588441972/1","ok":0}';

  eval {
    HiveJSO->new_via_json($json);
  };

  like($@,qr/ok attribute must be set to 1/,'ok attribute must be set to 1');
}

{
  my $json = '{"u":"202481588441972/1","x":0}';

  eval {
    HiveJSO->new_via_json($json);
  };

  like($@,qr/error_code must be positive integer above 0/,'error_code must be positive integer above 0');
}

done_testing;
