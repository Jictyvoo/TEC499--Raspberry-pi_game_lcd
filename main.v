module main

import time
import rpi_gpio

fn main() {
	mut gpio := rpi_gpio.Gpio{}
	if gpio.export_pin("24") {
		time.sleep_ms(5)
		mut gpio_24 := gpio.get_pin("24")
		if gpio_24.set_direction(false) {
			time.sleep_ms(5)
			mut to_write := false
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
