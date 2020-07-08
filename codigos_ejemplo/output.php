<?php
function ordenamiento_burbuja ($lista=array( , $TAM ){
$i;
$j;
$temp );
for( $i = 1;
$i < $TAM;
$i++ )
for( $j = 0;
$j < $TAM - 1;
$j++ )
if ( $lista[ $j ] > $lista[ $j + 1 ])
{
$temp = $lista[ $j ];
$lista[ $j ] = $lista[ $j + 1 ];
$lista[ $j + 1 ] = $temp;
}
}
?>
