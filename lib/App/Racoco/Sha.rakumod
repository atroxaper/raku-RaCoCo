unit module App::Racoco::Sha;
use nqp;

role Sha is export {
	method uc(Str() $obj) { ... }

  method lc(Str() $obj) { ... }
}

class NQPSha does Sha {
  method uc(Str() $obj) {
    nqp::sha1($obj)
  }

  method lc(Str() $obj) {
    self.uc($obj).lc
  }
}

our sub create() {
  NQPSha
}