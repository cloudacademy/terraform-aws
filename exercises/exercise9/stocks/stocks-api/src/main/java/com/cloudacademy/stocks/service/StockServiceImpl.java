package com.cloudacademy.stocks.service;

import lombok.AllArgsConstructor;

import org.springframework.stereotype.Service;

import com.cloudacademy.stocks.entity.Stock;
import com.cloudacademy.stocks.repo.StockRepository;

import java.util.List;

@Service
@AllArgsConstructor
public class StockServiceImpl implements StockService {

    private StockRepository stockRepository;

    @Override
    public Stock createStock(final Stock stock) {
        return stockRepository.save(stock);
    }

    @Override
    public List<Stock> getAllStocks() {
        return stockRepository.findAll();
    }
}
