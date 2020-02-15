module rpi_gpio

import os

struct Pin {
	mut:
		number int = 0
		direction bool = false
		exported bool = false
}

pub struct Gpio {
	pub: null_pin Pin = Pin{}
	mut: pins map[string]Pin
}

pub fn (gpio mut Gpio) export_pin(number string) bool {
	if !(number in gpio.pins) {
		gpio.pins[number] = Pin{number: number.int()}
	}
	mut pin := gpio.pins[number]
	if !os.exists("/sys/class/gpio/gpio" + number) {
		if os.exists("/sys/class/gpio/export") {
			mut export_file := os.create("/sys/class/gpio/export") or {
				return false
			}
			export_file.write(number)
			export_file.close()
		}
	}
	if os.exists("/sys/class/gpio/gpio" + number) {
		pin.exported = true
	}
	return pin.exported
}

pub fn (gpio mut Gpio) unexport_pin(number string) bool {
	if !(number in gpio.pins) {
		gpio.pins[number] = Pin{number: number.int()}
	}
	mut pin := gpio.pins[number]
	if os.exists("/sys/class/gpio/unexport") {
		mut unexport_file := os.create("/sys/class/gpio/unexport") or {
			return false
		}
		unexport_file.write(number)
		unexport_file.close()
	}
	pin.exported = os.exists("/sys/class/gpio/gpio" + number)
	return pin.exported
}

pub fn (gpio Gpio) get_pin(number string) Pin {
	if number in gpio.pins {
		return gpio.pins[number]
	}
	return gpio.null_pin
}

/*true - in | false - out*/
pub fn (pin mut Pin) set_direction(direction bool) bool {
	if pin.exported {
		path := "/sys/class/gpio/gpio" + pin.number.str() + "/direction"
		mut file := os.create(path) or {
			return false
		}
		if direction {
			file.write("in")
		} else {
			file.write("out")
		}
		file.close()
		pin.direction = direction
		return true
	}
	return false
}

pub fn (pin Pin) read() int {
	if pin.exported && pin.direction {
		path := "/sys/class/gpio/gpio" + pin.number.str() + "/value"
		readed := os.read_file(path) or {
			return -2
		}
		value := readed.int()
		return value
	}
	return -1
}

pub fn (pin Pin) write(value int) bool {
	if pin.exported && !pin.direction {
		path := "/sys/class/gpio/gpio" + pin.number.str() + "/value"
		mut file := os.create(path) or {
			println("$path error opeining file")
			return false
		}
		file.write(value.str())
		file.close()
		return true
	}
	return false
}
