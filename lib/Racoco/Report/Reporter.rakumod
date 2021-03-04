unit module Racoco::Report::Reporter;

role Reporter is export {
  method make-from-data(:%coverable-lines, :%covered-lines --> Reporter) { ... }
  method write(:$lib --> IO::Path) { ... }
}