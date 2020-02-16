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
		temp_pin.set_direction(direction)
		lcd.data[index] = temp_pin
	}
}

pub fn (lcd mut Lcd) export_default(gpio mut Gpio) {
	gpio.export_pin("17")
	lcd.data[0] = gpio.get_pin("17")
	gpio.export_pin("27")
	lcd.data[1] = gpio.get_pin("27")
	gpio.export_pin("22")
	lcd.data[2] = gpio.get_pin("22")
	gpio.export_pin("5")
	lcd.data[3] = gpio.get_pin("5")
	gpio.export_pin("6")
	lcd.data[4] = gpio.get_pin("6")
	gpio.export_pin("26")
	lcd.data[5] = gpio.get_pin("26")
	gpio.export_pin("25")
	lcd.data[6] = gpio.get_pin("25")
	gpio.export_pin("16")
	lcd.data[7] = gpio.get_pin("16")
	lcd.set_direction(false)
}

pub fn (lcd mut Lcd) clear_display() {
	lcd.set_direction(false)
	lcd.enable.write(1)
	lcd.rs.write(0)
	lcd.rw.write(0)
	for index := 1; index < 8; index++ {
		lcd.data[index].write(0)
	}
	lcd.data[0].write(1)
	lcd.enable.write(0)
	time.sleep_ms(2)
}

pub fn (lcd mut Lcd) home_cursor(b0 int) {
	lcd.set_direction(false)
	lcd.enable.write(1)
	lcd.rs.write(0)
	lcd.rw.write(0)
	for index := 2; index < 8; index++ {
		lcd.data[index].write(0)
	}
	lcd.data[1].write(1)
	lcd.data[0].write(b0)
	lcd.enable.write(0)
	time.sleep_ms(2)
}

pub fn (lcd mut Lcd) working_mode(x int, s int) {
	lcd.set_direction(false)
	lcd.enable.write(1)
	lcd.rs.write(0)
	lcd.rw.write(0)
	for index := 3; index < 8; index++ {
		lcd.data[index].write(0)
	}
	lcd.data[2].write(1)
	lcd.data[1].write(x)
	lcd.data[0].write(s)
	lcd.enable.write(0)
	time.sleep_ms(1)
}

pub fn (lcd mut Lcd) display_controller(d int, c int, b int) {
	lcd.set_direction(false)
	lcd.enable.write(1)
	lcd.rs.write(0)
	lcd.rw.write(0)
	for index := 4; index < 8; index++ {
		lcd.data[index].write(0)
	}
	lcd.data[3].write(1)
	lcd.data[2].write(d)
	lcd.data[1].write(c)
	lcd.data[0].write(b)
	lcd.enable.write(0)
	time.sleep_ms(1)
}

pub fn (lcd mut Lcd) move_cursor_message(c int, r int) {
	lcd.set_direction(false)
	lcd.enable.write(1)
	lcd.rs.write(0)
	lcd.rw.write(0)
	for index := 5; index < 8; index++ {
		lcd.data[index].write(0)
	}
	lcd.data[4].write(1)
	lcd.data[3].write(c)
	lcd.data[2].write(r)
	lcd.enable.write(0)
	time.sleep_ms(1)
}

pub fn (lcd mut Lcd) sets_use_mode(y int, n int, f int) {
	lcd.set_direction(false)
	lcd.enable.write(1)
	lcd.rs.write(0)
	lcd.rw.write(0)
	for index := 6; index < 8; index++ {
		lcd.data[index].write(0)
	}
	lcd.data[5].write(1)
	lcd.data[4].write(y)
	lcd.data[3].write(n)
	lcd.data[2].write(f)
	lcd.enable.write(0)
	time.sleep_ms(1)
}

pub fn (lcd mut Lcd) set_cgram_address(b5 int, b4 int, b3 int, b2 int, b1 int, b0 int) {
	lcd.set_direction(false)
	lcd.enable.write(1)
	lcd.rs.write(0)
	lcd.rw.write(0)
	lcd.data[7].write(0)
	lcd.data[6].write(1)
	lcd.data[5].write(b5)
	lcd.data[4].write(b4)
	lcd.data[3].write(b3)
	lcd.data[2].write(b2)
	lcd.data[1].write(b1)
	lcd.data[0].write(b0)
	lcd.enable.write(0)
	time.sleep_ms(1)
}

pub fn (lcd mut Lcd) set_ddram_address(b6 int, b5 int, b4 int, b3 int, b2 int, b1 int, b0 int) {
	lcd.set_direction(false)
	lcd.enable.write(1)
	lcd.rs.write(0)
	lcd.rw.write(0)
	lcd.data[7].write(1)
	lcd.data[6].write(b6)
	lcd.data[5].write(b5)
	lcd.data[4].write(b4)
	lcd.data[3].write(b3)
	lcd.data[2].write(b2)
	lcd.data[1].write(b1)
	lcd.data[0].write(b0)
	lcd.enable.write(0)
	time.sleep_ms(1)
}

pub fn (lcd mut Lcd) write(b7 int, b6 int, b5 int, b4 int, b3 int, b2 int, b1 int, b0 int) {
	lcd.set_direction(false)
	lcd.enable.write(1)
	lcd.rs.write(0)
	lcd.rw.write(1)
	lcd.data[7].write(b7)
	lcd.data[6].write(b6)
	lcd.data[5].write(b5)
	lcd.data[4].write(b4)
	lcd.data[3].write(b3)
	lcd.data[2].write(b2)
	lcd.data[1].write(b1)
	lcd.data[0].write(b0)
	lcd.enable.write(0)
	time.sleep_ms(1)
}

pub fn (lcd mut Lcd) read() string {
	lcd.set_direction(true)
	lcd.enable.write(1)
	lcd.rs.write(1)
	lcd.rw.write(1)
	lcd.enable.write(0)
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
