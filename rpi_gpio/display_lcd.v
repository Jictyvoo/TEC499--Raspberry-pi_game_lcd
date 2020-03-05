module rpi_gpio

import time

pub struct Lcd {
	mut:
		rs Pin
		rw Pin
		enable Pin
		data [8]rpi_gpio.Pin
}

fn (lcd mut Lcd) set_direction(direction bool) {
	mut temp_pin := lcd.data[0]
	for index := 0; index < 8; index++ {
		temp_pin = lcd.data[index]
		if temp_pin.direction == direction {
			temp_pin.set_direction(direction)
			lcd.data[index] = temp_pin
		}
	}
}

pub fn (lcd mut Lcd) export_default(gpio mut Gpio) {
	gpio.export_pin("17")
	lcd.data[0] = gpio.get_pin("17")
	gpio.export_pin("27")
	lcd.data[1] = gpio.get_pin("27")
	gpio.export_pin("22")
	lcd.data[2] = gpio.get_pin("22")
	gpio.export_pin("10")
	lcd.data[3] = gpio.get_pin("10")
	gpio.export_pin("9")
	lcd.data[4] = gpio.get_pin("9")
	gpio.export_pin("11")
	lcd.data[5] = gpio.get_pin("11")
	gpio.export_pin("5")
	lcd.data[6] = gpio.get_pin("5")
	gpio.export_pin("6")
	lcd.data[7] = gpio.get_pin("6")
	gpio.export_pin("2")
	lcd.rs = gpio.get_pin("2")
	lcd.rs.set_direction(false)
	gpio.export_pin("3")
	lcd.rw = gpio.get_pin("3")
	lcd.rw.set_direction(false)
	gpio.export_pin("4")
	lcd.enable = gpio.get_pin("4")
	lcd.enable.set_direction(false)
	lcd.set_direction(false)
}

pub fn (lcd mut Lcd) instruction_4bit(rs int, rw int, b7 int, b6 int, b5 int, b4 int) {
	lcd.set_direction(false)
	lcd.enable.write(1)
	lcd.rs.write(0)
	lcd.rw.write(1)
	lcd.data[4].write(b4)
	lcd.data[5].write(b5)
	lcd.data[6].write(b6)
	lcd.data[7].write(b7)
	time.usleep(500)
	lcd.enable.write(0)
	time.usleep(500)
}

pub fn (lcd mut Lcd) home_cursor() {
	lcd.instruction_4bit(0, 0, 0, 0, 0, 0) //return address to home
	lcd.instruction_4bit(0, 0, 0, 0, 1, 0)
	time.sleep_ms(3)
}

pub fn (lcd mut Lcd) shift_cursor(to int) {
	lcd.instruction_4bit(0, 0, 0, 0, 0, 1) //shift cursor to left
	lcd.instruction_4bit(0, 0, 0, to, 0, 0)
	time.sleep_ms(3)
}

pub fn (lcd mut Lcd) clear_display() {
	lcd.instruction_4bit(0,0,0,0,0,0)	// Clear Display
	lcd.instruction_4bit(0,0,0,0,0,1)
	time.sleep_ms(3)
}

pub fn (lcd mut Lcd) read() string {
	lcd.set_direction(true)
	lcd.enable.write(0)
	lcd.rs.write(1)
	lcd.rw.write(1)
	lcd.enable.write(1)
	time.sleep_ms(1)
	b7 := lcd.data[7].read()
	b6 := lcd.data[6].read()
	b5 := lcd.data[5].read()
	b4 := lcd.data[4].read()
	b3 := lcd.data[3].read()
	b2 := lcd.data[2].read()
	b1 := lcd.data[1].read()
	b0 := lcd.data[0].read()
	return "${b7}${b6}${b5}${b4}${b3}${b2}${b1}${b0}"
}

pub fn (lcd mut Lcd) initialize_4bit() {
	time.usleep(100000)	// in miliseconds
	lcd.instruction_4bit(0,0,0,0,1,1)	// Function Set
	time.usleep(5000)	// in miliseconds
	lcd.instruction_4bit(0,0,0,0,1,1)
	time.usleep(100)	// in microseconds
	lcd.instruction_4bit(0,0,0,0,1,1)
	time.usleep(100)	// in microseconds
	lcd.instruction_4bit(0,0,0,0,1,0)	// Real Function Set 2H
	time.usleep(100)	// in microseconds

	/*The LCD controller is now in the 4-bit mode.*/
	lcd.instruction_4bit(0,0,0,0,1,0)	// Real Function Set 2H
	lcd.instruction_4bit(0,0,1,0,0,0)	// Real Function Set 8H
	time.usleep(100)	// in microseconds
	lcd.instruction_4bit(0,0,0,0,0,0)	// Real Function Set 0H
	lcd.instruction_4bit(0,0,1,0,0,0)	// Real Function Set 8H
	time.usleep(100)	// in microseconds
	lcd.instruction_4bit(0,0,0,0,0,0)	// Real Function Set 0H
	lcd.instruction_4bit(0,0,0,0,0,1)	// Real Function Set 8H
	time.usleep(3000)	// in miliseconds
	lcd.instruction_4bit(0,0,0,0,0,0)	// Real Function Set 0H
	lcd.instruction_4bit(0,0,0,1,1,0)	// Real Function Set 6H
	time.usleep(100)	// in microseconds

	/*Initializing end - display off*/
	lcd.instruction_4bit(0,0,0,0,0,0)	// Real Function Set 0H
	lcd.instruction_4bit(0,0,1,1,0,0)	// Real Function Set 6H
	time.usleep(100)	// in microseconds
}
