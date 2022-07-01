sub mod($arg) is export {
	if $arg {
		return 'mod'
	} else {
		return 'dom'
	}
}