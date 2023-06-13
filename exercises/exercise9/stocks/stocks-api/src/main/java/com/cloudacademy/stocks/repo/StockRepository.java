package com.cloudacademy.stocks.repo;

import org.springframework.data.jpa.repository.JpaRepository;
import com.cloudacademy.stocks.entity.Stock;

public interface StockRepository extends JpaRepository<Stock, Long> {
}
