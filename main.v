module main

import time
import rpi_gpio

#flag -O3

fn always_read(gpio_23 rpi_gpio.Pin) {
	mut counter := 0
	mut state := 0
	mut current_state := 0
	for {
		current_state = gpio_23.read()
		if current_state == 1 && current_state != state {
			counter++
			println("counter: $counter")
		}
		state = current_state
		time.sleep_ms(10)
	}
}

fn initialize_lcd(gpio mut rpi_gpio.Gpio) {
	initial_time := time.ticks()
	println("Started Initialization")
	mut lcd := rpi_gpio.Lcd{}
	lcd.export_default(mut gpio)
	time.sleep_ms(16)
	lcd.write_fast(0,0,0,0,1,1,1,0,0,0)
	time.sleep_ms(15)
	lcd.write_fast(0,0,0,0,1,1,1,0,0,1)
	time.sleep_ms(15)
	lcd.write_fast(0,0,0,0,0,1,0,1,0,0)
	time.sleep_ms(15)
	lcd.write_fast(0,0,0,1,0,1,1,1,1,0)
	time.sleep_ms(15)
	lcd.write_fast(0,0,0,1,1,0,1,1,0,1)
	time.sleep_ms(15)
	lcd.write_fast(0,0,0,1,1,1,0,0,0,0)
	time.sleep_ms(15)
	lcd.write_fast(0,0,0,0,0,0,1,1,0,0)
	time.sleep_ms(15)
	lcd.write_fast(0,0,0,0,0,0,0,1,1,0)
	time.sleep_ms(15)
	lcd.write_fast(0,0,0,0,0,0,0,0,0,1)
	time.sleep_ms(15)
	println("Ended initialization after ${time.ticks() - initial_time} ticks")
	lcd.write(0,1,0,0,1,0,0,0)
}

fn main() {
	mut gpio := rpi_gpio.Gpio{}
	go initialize_lcd(&gpio)
	if gpio.export_pin("24") && gpio.export_pin("23") {
		time.sleep_ms(5)
		mut gpio_24 := gpio.get_pin("24")
		mut gpio_23 := gpio.get_pin("23")
		if gpio_24.set_direction(false) && gpio_23.set_direction(true) {
			time.sleep_ms(5)
			mut to_write := false
			go always_read(gpio_23)
			for {
				if to_write {
					println(gpio_24.write(1))
				} else{
					println(gpio_24.write(0))
				}
				to_write = !to_write
				time.sleep(3)
			}
		}
	}
}
