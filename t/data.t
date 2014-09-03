#!/usr/bin/env perl
use strict;
use warnings;
use Test::More;
use HiveJSO;

{
  my $json = '{"unit":"202481588441972/1","data":[[1,1],[2,2]]}';

  my $obj = HiveJSO->new_via_json($json);

  isa_ok($obj,'HiveJSO','object');
  is_deeply($obj->data,[[1,1],[2,2]],'Proper data');
  ok(!$obj->has_ok,'Has no ok attribute');
  ok(!$obj->has_timestamp,'has no timestamp');
  ok(!$obj->has_product_id,'has no product_id');
  ok(!$obj->has_error_code,'has no error_code');
}

{
  my $json = '{"unit":"202481588441972/1","data":[[0,1]]}';

  eval {
    HiveJSO->new_via_json($json);
  };

  like($@,qr/first value in array inside 'data' array must be positive integer/,"first value in array inside 'data' array must be positive integer");
}

{
  my $json = '{"unit":"202481588441972/1","data":[[]]}';

  eval {
    HiveJSO->new_via_json($json);
  };

  like($@,qr/array inside 'data' array needs at least one value/,"array inside 'data' array needs at least one value");
}

{
  my $json = '{"unit":"202481588441972/1","data":[2,[1,1]]}';

  eval {
    HiveJSO->new_via_json($json);
  };

  like($@,qr/values inside the 'data' array must be arrays/,"values inside the 'data' array must be arrays");
}

done_testing;
