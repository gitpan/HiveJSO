#!/usr/bin/env perl
use strict;
use warnings;
use Test::More;
use HiveJSO;

{
  my $json = '{"unit":"1234567890/0","ok":1}';

  my $obj = HiveJSO->new_via_json($json);

  isa_ok($obj,'HiveJSO','object');
  is($obj->hivejso_checksum,"650973972",'Proper generated checksum');
  ok(!$obj->has_checksum,'Object has no checksum');
}

{
  my $json = '{"unit":"1234567890/0","ok":1,"checksum":650973972}';

  my $obj = HiveJSO->new_via_json($json);

  isa_ok($obj,'HiveJSO','object');
  ok($obj->has_checksum,'Object has checksum');
}

{
  my $json = '{"u":"1234567890/0","ok":1,"c":4121211587}';

  my $obj = HiveJSO->new_via_json($json);

  isa_ok($obj,'HiveJSO','object');
  ok($obj->has_checksum,'Object has checksum');
}

{
  my $json = '{"u":"1234567890/0","ok":1,"c":1234}';

  eval {
    HiveJSO->new_via_json($json);
  };

  like($@,qr/invalid HiveJSO checksum/,'Checksum error is coming up');
}

{
  my $json = '{"u":"202481588441972/1","d":[[1,100],[2,200]],"c":3488818089}';

  my $obj = HiveJSO->new_via_json($json);

  isa_ok($obj,'HiveJSO','object');
  ok($obj->has_checksum,'Object has checksum');
}

done_testing;
