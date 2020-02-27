<?php
/* This is a script to convert the csv of species to dart objects.

 * USAGE
 * php csv2model.php filename.csv
 */

$model_name = 'Species';
$model_name_lower = strtolower($model_name);

$output = <<<DART
import 'package:oltrace/models/$model_name_lower.dart';

final List<$model_name> $model_name_lower = <$model_name>[

DART;
echo $output;
$csv_file = file_get_contents($argv[1]);
$lines = explode("\n",$csv_file);
$lines = array_reverse($lines);
array_pop($lines);
$lines = array_reverse($lines);
$id = 0;

foreach($lines as $line) {
    $column = explode(';', $line);
    $column = array_map('rtrim',$column);
    $code = <<<DART
    $model_name(
        id: $id,
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
$id++;
}

$output .= '];';
file_put_contents('species.dart',$output);
