#!/usr/bin/env perl
use strict;
use warnings;
use Test::More;
use HiveJSO;

{
  my $stream = '7890,"ok":1}{"did":1234567890,"ok":1}{"did":123456';
  my @result = HiveJSO->parse($stream);
  is(scalar @result,3,'correct amount of results');
  my ( $pre, $obj, $post ) = @result;

  is($pre,'7890,"ok":1}','Garbage before object');
  isa_ok($obj,'HiveJSO','object');
  is($obj->did,1234567890,'Proper Drone ID');
  ok($obj->has_ok,'Has an ok attribute');
  is($obj->ok,1,'ok value is 1');
  ok(!$obj->has_timestamp,'has no timestamp');
  ok(!$obj->has_device_id,'has no device_id');
  ok(!$obj->has_error_code,'has no error_code');
  is($post,'{"did":123456','Garbage after object');

}

{
  my $stream = '7890,"ok":1}{"did":1234567890,"ok":1}{"did":1234567890,"ok":1}{"did":123456';

  my @result = HiveJSO->parse($stream);
  is(scalar @result,4,'correct amount of results');
  my ( $pre, $obj, $obj2, $post ) = @result;

  is($pre,'7890,"ok":1}','Garbage before object');
  isa_ok($obj,'HiveJSO','object');
  isa_ok($obj2,'HiveJSO','object');
  is($obj->did,1234567890,'Proper Drone ID');
  ok($obj->has_ok,'Has an ok attribute');
  is($obj->ok,1,'ok value is 1');
  ok(!$obj->has_timestamp,'has no timestamp');
  ok(!$obj->has_device_id,'has no device_id');
  ok(!$obj->has_error_code,'has no error_code');
  is($obj2->did,1234567890,'Proper Drone ID');
  ok($obj2->has_ok,'Has an ok attribute');
  is($obj2->ok,1,'ok value is 1');
  ok(!$obj2->has_timestamp,'has no timestamp');
  ok(!$obj2->has_device_id,'has no device_id');
  ok(!$obj2->has_error_code,'has no error_code');
  is($post,'{"did":123456','Garbage after object');
}

{
  my $stream = '{"did":1234567890,"ok":1}{"did":1234567890,"ok":1}';

  my @result = HiveJSO->parse($stream);
  is(scalar @result,2,'correct amount of results');
  my ( $obj, $obj2 ) = @result;

  isa_ok($obj,'HiveJSO','object');
  isa_ok($obj2,'HiveJSO','object');
  is($obj->did,1234567890,'Proper Drone ID');
  ok($obj->has_ok,'Has an ok attribute');
  is($obj->ok,1,'ok value is 1');
  ok(!$obj->has_timestamp,'has no timestamp');
  ok(!$obj->has_device_id,'has no device_id');
  ok(!$obj->has_error_code,'has no error_code');
  is($obj2->did,1234567890,'Proper Drone ID');
  ok($obj2->has_ok,'Has an ok attribute');
  is($obj2->ok,1,'ok value is 1');
  ok(!$obj2->has_timestamp,'has no timestamp');
  ok(!$obj2->has_device_id,'has no device_id');
  ok(!$obj2->has_error_code,'has no error_code');
}

done_testing;

