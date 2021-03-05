unit module Racoco::Report::Reporter;

role Reporter is export {
  method make-from-data(:%coverable-lines, :%covered-lines --> Reporter) { ... }
  method read(IO::Path :$lib --> Reporter) { ... }
  method write(IO::Path :$lib --> IO::Path) { ... }
}