unit module Racoco::Sha;
use nqp;

class Sha {
  method uc(Str() \obj) {
    nqp::sha1(obj)
  }

  method lc(Str() \obj) {
    self.uc(obj).lc
  }
}

our sub create() {
  Sha.new()
}