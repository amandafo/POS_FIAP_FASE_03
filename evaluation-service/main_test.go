package main

import (
	"net/http"
	"net/http/httptest"
	"strings"
	"testing"
)

func TestHealthHandler(t *testing.T) {
	app := &App{}
	recorder := httptest.NewRecorder()
	request := httptest.NewRequest(http.MethodGet, "/health", nil)

	app.healthHandler(recorder, request)

	if recorder.Code != http.StatusOK {
		t.Fatalf("status esperado %d, recebido %d", http.StatusOK, recorder.Code)
	}
	if !strings.Contains(recorder.Body.String(), `"status":"ok"`) {
		t.Fatalf("resposta inesperada: %s", recorder.Body.String())
	}
}

func TestEvaluationDisabledFlag(t *testing.T) {
	app := &App{}
	info := &CombinedFlagInfo{Flag: &Flag{Name: "checkout", IsEnabled: false}}

	if app.runEvaluationLogic(info, "usuario-1") {
		t.Fatal("flag desabilitada deve retornar false")
	}
}

func TestEvaluationEnabledWithoutRule(t *testing.T) {
	app := &App{}
	info := &CombinedFlagInfo{Flag: &Flag{Name: "checkout", IsEnabled: true}}

	if !app.runEvaluationLogic(info, "usuario-1") {
		t.Fatal("flag habilitada sem regra deve retornar true")
	}
}

func TestEvaluationPercentageBoundaries(t *testing.T) {
	app := &App{}
	flag := &Flag{Name: "checkout", IsEnabled: true}

	all := &CombinedFlagInfo{Flag: flag, Rule: &TargetingRule{
		IsEnabled: true,
		Rules:     Rule{Type: "PERCENTAGE", Value: float64(100)},
	}}
	none := &CombinedFlagInfo{Flag: flag, Rule: &TargetingRule{
		IsEnabled: true,
		Rules:     Rule{Type: "PERCENTAGE", Value: float64(0)},
	}}

	if !app.runEvaluationLogic(all, "usuario-1") {
		t.Fatal("regra de 100 por cento deve retornar true")
	}
	if app.runEvaluationLogic(none, "usuario-1") {
		t.Fatal("regra de 0 por cento deve retornar false")
	}
}

func TestDeterministicBucket(t *testing.T) {
	first := getDeterministicBucket("usuario-flag")
	second := getDeterministicBucket("usuario-flag")
	if first != second {
		t.Fatal("bucket deve ser deterministico")
	}
	if first < 0 || first > 99 {
		t.Fatalf("bucket fora do intervalo: %d", first)
	}
}

func TestBuildServiceURL(t *testing.T) {
	serviceURL, err := buildServiceURL("http://flag-service:8002", "flags", "checkout-novo")
	if err != nil {
		t.Fatalf("erro inesperado: %v", err)
	}
	if serviceURL != "http://flag-service:8002/flags/checkout-novo" {
		t.Fatalf("URL inesperada: %s", serviceURL)
	}
}

func TestBuildServiceURLRejectsPathInjection(t *testing.T) {
	if _, err := buildServiceURL("http://flag-service:8002", "flags", "../admin"); err == nil {
		t.Fatal("identificador com caminho deveria ser recusado")
	}
}

func TestBuildServiceURLRejectsUnsafeScheme(t *testing.T) {
	if _, err := buildServiceURL("file:///etc", "flags", "checkout"); err == nil {
		t.Fatal("protocolo inseguro deveria ser recusado")
	}
}
