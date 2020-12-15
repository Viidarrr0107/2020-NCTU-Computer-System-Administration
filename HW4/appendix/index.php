<?php
	$query = $_SERVER['REQUEST_URI'];
	$parm = explode("/", $query);
	if ($parm[1] == 'app') {
		if (empty($parm[2])){
			echo "<p>App route enabled</p>";
		}
		elseif ($parm[2] == 'display') {
			echo "<p>Display: ".$parm[3]."</p>";
		}
		elseif ($parm[2] == 'calculate') {
			$opds = explode("+", $parm[3]);
			$result = intval($opds[0]) + intval($opds[1]);
			echo "<p>Result: ".strval($result)."</p>";
		}
		elseif (strpos($parm[2], '?vid') !== false) {
			$opds = explode("&", $parm[2]);
			$vid = substr($opds[0], 5);
			$t = substr($opds[1], 5);
			header("Location: https://youtu.be/".$vid."?t=".$t);
			die();
		}
		else {
			for ($i = 1; $i < count($parm); $i++){
				echo "<p>arg= ".$parm[$i]."</p>";
			}
		}
	}
	else {
		http_response_code(404);
	}
?>
