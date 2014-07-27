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

  my @seek_result = HiveJSO->parse_seek($stream);
  my ( $seek_obj, $seek_post ) = @seek_result;

  isa_ok($seek_obj,'HiveJSO','object');
  is($seek_obj->did,1234567890,'Proper Drone ID');
  ok($seek_obj->has_ok,'Has an ok attribute');
  is($seek_obj->ok,1,'ok value is 1');
  ok(!$seek_obj->has_timestamp,'has no timestamp');
  ok(!$seek_obj->has_device_id,'has no device_id');
  ok(!$seek_obj->has_error_code,'has no error_code');
  is($seek_post,'{"did":1234567890,"ok":1}{"did":123456','Garbage after object');

  my @second_seek_result = HiveJSO->parse_seek($seek_post);
  my ( $second_seek_obj, $second_seek_post ) = @second_seek_result;

  isa_ok($second_seek_obj,'HiveJSO','object');
  is($second_seek_obj->did,1234567890,'Proper Drone ID');
  ok($second_seek_obj->has_ok,'Has an ok attribute');
  is($second_seek_obj->ok,1,'ok value is 1');
  ok(!$second_seek_obj->has_timestamp,'has no timestamp');
  ok(!$second_seek_obj->has_device_id,'has no device_id');
  ok(!$second_seek_obj->has_error_code,'has no error_code');
  is($second_seek_post,'{"did":123456','Garbage after object');

  my @third_seek_result = HiveJSO->parse_seek($second_seek_post);
  my ( $third_seek_obj, $third_seek_post ) = @third_seek_result;

  is($third_seek_obj,undef,'Object is undef');
  is($third_seek_post,'{"did":123456','Garbage after object');
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

{
  my $stream = '7890,"ok":1}{"did":12345::::67890,""""ok":1}{"did":123456';
  my @result = HiveJSO->parse($stream);
  is(scalar @result,3,'correct amount of results');
  my ( $pre, $obj, $post ) = @result;
  is($pre,'7890,"ok":1}','Garbage before object');
  isa_ok($obj,'HiveJSO::Error','object');
  is($obj->garbage,'{"did":12345::::67890,""""ok":1}','Garbage is ok in error');
  is($post,'{"did":123456','Garbage after object');
}

done_testing;

