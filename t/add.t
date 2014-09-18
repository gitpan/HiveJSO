#!/usr/bin/env perl
use strict;
use warnings;
use Test::More;
use HiveJSO;

{
  my $json = '{"unit":"1234567890/0","ok":1}';

  my $orig = HiveJSO->new_via_json($json);
  my $obj = $orig->add(
    timestamp => 3014000316,
  );

  isa_ok($obj,'HiveJSO','object');
  ok(!$orig->has_timestamp,'orig has no timestamp');
  ok(!$orig->has_checksum,'orig has no checksum');
  is($orig->unit,"1234567890/0",'orig proper Unit');
  isnt($obj,$orig,'object from add is not the original one');
  ok(!$obj->has_checksum,'new obj has no checksum');
  is($obj->unit,"1234567890/0",'Proper Unit');
  ok($obj->has_ok,'Has an ok attribute');
  is($obj->ok,1,'ok value is 1');
  ok($obj->has_timestamp,'has timestamp');
  is($obj->timestamp,3014000316,'proper timestamp');
}

{
  my $json = '{"unit":"1234567890/0","ok":1,"checksum":650973972}';

  my $orig = HiveJSO->new_via_json($json);
  my $obj = $orig->add_short(
    t => 3014000316,
  );

  isa_ok($obj,'HiveJSO','object');
  ok(!$orig->has_timestamp,'orig has no timestamp');
  ok($orig->has_checksum,'orig has checksum');
  isnt($obj,$orig,'object from add is not the original one');
  ok($obj->has_checksum,'new obj has checksum');
  is($obj->checksum,'1358463339','new obj checksum is correct');
  is($obj->unit,"1234567890/0",'Proper Unit ID');
  ok($obj->has_ok,'Has an ok attribute');
  is($obj->ok,1,'ok value is 1');
  ok($obj->has_timestamp,'has timestamp');
  is($obj->timestamp,3014000316,'proper timestamp');
}

done_testing;
