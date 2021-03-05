unit module Racoco::Report::Report;

enum COLOR is export <GREEN RED PURPLE>;

sub percent($a, $b --> Real) {
  return 100 if $b == 0;
  min(100, (($a / $b) * 100 * 10).Int / 10);
}

class FileReportData is export {
  has Str $.file-name;
  has Set $.green;
  has Set $.red;
  has Set $.purple;

  submethod BUILD(Str :$!file-name, Set() :$!green, Set() :$!red, Set() :$!purple) {}

  method percent(--> Real) {
    my $covered = self.covered();
    my $coverable = self.coverable();
    return 100 if $coverable == 0;
    percent($covered, $coverable);
  }

  method color(Int :$line --> COLOR) {
    return GREEN if $!green{$line};
    return RED if $!red{$line};
    return PURPLE if $!purple{$line};
    Nil
  }

  method covered(--> Int) {
    $!green.elems + $!purple.elems
  }

  method coverable(--> Int) {
    $!green.elems + $!red.elems
  }
}

multi sub infix:<eqv>(FileReportData $data1, FileReportData $data2) is export {
  $data1.file-name eqv $data2.file-name &&
  $data1.green eqv $data2.green &&
  $data1.red eqv $data2.red &&
  $data1.purple eqv $data2.purple
}

class Report is export {
  has FileReportData %!data;

  submethod BUILD(:@fileReportData) {
    for @fileReportData {
      %!data{$_.file-name} = $_
    };
  }

  method percent(--> Real) {
    return 100 if %!data.elems == 0;
    my ($covered, $coverable) = 0, 0;
    %!data.values.map({
      $covered += .covered;
      $coverable += .coverable;
    });
    percent($covered, $coverable)
  }

  method data(:$file-name --> FileReportData) {
    %!data{$file-name}
  }

  method all-data(--> Positional) {
    %!data.values.sort(*.file-name).List
  }
}

multi sub infix:<eqv>(Report:D $report1, Report:D $report2) is export {
  return False unless $report1.all-data.elems == $report2.all-data.elems;
  for $report1.all-data Z $report2.all-data -> ($l, $r) {
    return False unless $l eqv $r;
  }
  True
}