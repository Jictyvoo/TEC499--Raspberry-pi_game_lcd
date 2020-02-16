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

fn main() {
	mut gpio := rpi_gpio.Gpio{}
	mut lcd := rpi_gpio.Lcd{}
	lcd.export_default(gpio)
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
