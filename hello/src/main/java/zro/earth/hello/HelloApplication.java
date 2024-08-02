package zro.earth.hello;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.client.RestTemplate;

@SpringBootApplication
@RestController
public class HelloApplication {

	private RestTemplate restTemplate = new RestTemplate();

	public static void main(String[] args) {
		SpringApplication.run(HelloApplication.class, args);
	}

	String url = "http://hello-service/world";

	@GetMapping("/")
	public String hello() {
		return "Hello," + restTemplate.getForObject(url, String.class);
	}

	@GetMapping("/world")
	public String world() {
		return " world!";
	}

}
