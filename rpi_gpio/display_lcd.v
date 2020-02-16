module rpi_gpio

import time

pub struct Lcd {
	mut:
		rs Pin
		rw Pin
		data []Pin = [Pin{}].repeat(8)
}

fn (lcd mut Lcd) export_default(gpio mut Gpio) {
	gpio.export_pin("17")
	mut temp_pin := gpio.get_pin("17")
	temp_pin.set_direction(false)
	lcd.data[0] = temp_pin
	gpio.export_pin("27")
	temp_pin = gpio.get_pin("27")
	temp_pin.set_direction(false)
	lcd.data[1] = temp_pin
	gpio.export_pin("22")
	temp_pin = gpio.get_pin("22")
	temp_pin.set_direction(false)
	lcd.data[2] = temp_pin
	gpio.export_pin("5")
	temp_pin = gpio.get_pin("5")
	temp_pin.set_direction(false)
	lcd.data[3] = temp_pin
	gpio.export_pin("6")
	temp_pin = gpio.get_pin("6")
	temp_pin.set_direction(false)
	lcd.data[4] = temp_pin
	gpio.export_pin("26")
	temp_pin = gpio.get_pin("26")
	temp_pin.set_direction(false)
	lcd.data[5] = temp_pin
	gpio.export_pin("25")
	temp_pin = gpio.get_pin("25")
	temp_pin.set_direction(false)
	lcd.data[6] = temp_pin
	gpio.export_pin("16")
	temp_pin = gpio.get_pin("16")
	temp_pin.set_direction(false)
	lcd.data[7] = temp_pin
}

fn (lcd mut Lcd) clear_display() {
	lcd.rs.write(0)
	lcd.rw.write(0)
	for index := 1; index < 8; index++ {
		lcd.data[index].write(0)
	}
	lcd.data[0].write(1)
	time.sleep_ms(1.6)
}

fn (lcd mut Lcd) home_cursor(b0 int) {
	lcd.rs.write(0)
	lcd.rw.write(0)
	for index := 2; index < 8; index++ {
		lcd.data[index].write(0)
	}
	lcd.data[1].write(1)
	lcd.data[0].write(b0)
	time.sleep_ms(1.6)
}

fn (lcd mut Lcd) working_mode(x int, s int) {
	lcd.rs.write(0)
	lcd.rw.write(0)
	for index := 3; index < 8; index++ {
		lcd.data[index].write(0)
	}
	lcd.data[2].write(1)
	lcd.data[1].write(x)
	lcd.data[0].write(s)
	time.sleep_ms(1)
}

fn (lcd mut Lcd) display_controller(d int, c int, b int){
	lcd.rs.write(0)
	lcd.rw.write(0)
	for index := 4; index < 8; index++ {
		lcd.data[index].write(0)
	}
	lcd.data[3].write(1)
	lcd.data[2].write(d)
	lcd.data[1].write(c)
	lcd.data[0].write(b)
	time.sleep_ms(1)
}
