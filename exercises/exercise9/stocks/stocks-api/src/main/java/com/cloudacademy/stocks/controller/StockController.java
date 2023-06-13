package com.cloudacademy.stocks.controller;

import lombok.AllArgsConstructor;

import org.apache.commons.csv.CSVPrinter;
import org.apache.commons.csv.CSVFormat;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.core.io.Resource;
import org.springframework.http.HttpHeaders;
import org.springframework.core.io.InputStreamResource;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestBody;

import java.util.List;
import java.util.ArrayList;
import java.util.Arrays;
import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.PrintWriter;
import java.text.SimpleDateFormat;
import java.text.DecimalFormat;

import com.cloudacademy.stocks.entity.Stock;
import com.cloudacademy.stocks.service.StockService;

@RestController
@AllArgsConstructor
@RequestMapping("api/stocks")
public class StockController {

    private StockService stockService;

    // build create Stock REST API
    @PostMapping
    public ResponseEntity<Stock> createStock(@RequestBody Stock stock) {
        var savedStock = stockService.createStock(stock);
        return new ResponseEntity<>(savedStock, HttpStatus.CREATED);
    }

    // http://localhost:8080/api/stocks
    @CrossOrigin(origins = "*")
    @GetMapping
    public ResponseEntity<List<Stock>> getAllStocks() {
        var stocks = stockService.getAllStocks();
        return new ResponseEntity<>(stocks, HttpStatus.OK);
    }

    // http://localhost:8080/api/stocks/csv
    @CrossOrigin(origins = "*")
    @GetMapping(value = "/csv", produces = "text/csv")
    public ResponseEntity<Resource> exportCSV() {
        // replace this with your header (if required)
        String[] csvHeader = {
                "date", "open", "high", "low", "close", "volume"
        };

        // replace this with your data retrieving logic
        List<List<String>> csvBody = new ArrayList<>();
        List<Stock> stocks = stockService.getAllStocks();

        var dateFormatter = new SimpleDateFormat("yyyy-MM-dd");
        var numFormatter = new DecimalFormat("##.000000");

        for (var stock : stocks) {
            csvBody.add(Arrays.asList(
                dateFormatter.format(stock.getDate()),
                numFormatter.format(stock.getOpen()),
                numFormatter.format(stock.getHigh()),
                numFormatter.format(stock.getLow()),
                numFormatter.format(stock.getClose()),
                stock.getVolume().toString()
            ));
        }

        ByteArrayInputStream byteArrayOutputStream;

        try (
                var out = new ByteArrayOutputStream();

                var csvPrinter = new CSVPrinter(
                        new PrintWriter(out),
                        CSVFormat.DEFAULT.withHeader(csvHeader)
                );
        ) {
            for (var record : csvBody) {
                csvPrinter.printRecord(record);
            }

            // writing the underlying stream
            csvPrinter.flush();

            byteArrayOutputStream = new ByteArrayInputStream(out.toByteArray());
        } catch (IOException e) {
            throw new RuntimeException(e.getMessage());
        }

        var fileInputStream = new InputStreamResource(byteArrayOutputStream);

        var csvFileName = "stocks.csv";

        HttpHeaders headers = new HttpHeaders();
        headers.set(HttpHeaders.CONTENT_DISPOSITION, "attachment; filename=" + csvFileName);
        headers.set(HttpHeaders.CONTENT_TYPE, "text/csv");

        return new ResponseEntity<>(
                fileInputStream,
                headers,
                HttpStatus.OK
        );
    }
}
