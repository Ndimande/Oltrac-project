<?php
$output = <<<DART
import 'package:oltrace/models/species.dart';

final List<Species> species = <Species>[

DART;

$csv_file = file_get_contents($argv[1]);
$lines = explode("\n",$csv_file);
$lines = array_reverse($lines);
array_pop($lines);
$lines = array_reverse($lines);
foreach($lines as $line) {
    $column = explode(';', $line);
    $column = array_map('rtrim',$column);
    $code = <<<DART
    Species(
        alpha3Code: '{$column[0]}',
        taxonomicCode: '{$column[1]}',
        englishName: '{$column[2]}',
        scientificName: '{$column[3]}',
        family: '{$column[5]}',
        order: '{$column[6]}',
        majorGroup: '{$column[7]}',
        yearbookGroup: '{$column[8]}',
        isscaapGroup: '{$column[9]}',
        cpcClass: '{$column[10]}',
        cpcGroup: '{$column[11]}',
        caabCode: '{$column[12]}',
        australianName: '{$column[13]}',
    ),

DART;
$output .= $code;
}

$output .= '];';
file_put_contents('species.dart',$output);
