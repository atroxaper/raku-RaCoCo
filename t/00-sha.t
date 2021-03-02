use Test;
use lib 'lib';
use Racoco::Sha;

plan 4;

sub test($sha) {
  is $sha.uc('1ahs'), 'E82EFCCFBEB2F189ABB6D4BB79B02A20A277D04C', 'sha uc ok';
  is $sha.lc('1ahs'), 'e82efccfbeb2f189abb6d4bb79b02a20a277d04c', 'sha lc ok';
}

test(Racoco::Sha::NQPSha.new);
test(Racoco::Sha::create());

done-testing