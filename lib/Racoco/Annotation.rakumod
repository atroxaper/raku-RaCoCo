unit module Racoco::Annotation;

class Annotation is export {
  has $.file;
  has $.timestamp = now;
  has $.hashcode;
  has @.lines;

}

class AnnotationCalculator is export {
  method calc($path) {
    Annotation.new(:file($path))
  }
}