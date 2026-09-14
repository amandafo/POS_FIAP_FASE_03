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

func TestMasterKeyMiddlewareBlocksInvalidKey(t *testing.T) {
	app := &App{MasterKey: "master-segura"}
	nextCalled := false
	next := http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		nextCalled = true
	})
	recorder := httptest.NewRecorder()
	request := httptest.NewRequest(http.MethodPost, "/admin/keys", nil)
	request.Header.Set("Authorization", "Bearer incorreta")

	app.masterKeyAuthMiddleware(next).ServeHTTP(recorder, request)

	if recorder.Code != http.StatusForbidden {
		t.Fatalf("status esperado %d, recebido %d", http.StatusForbidden, recorder.Code)
	}
	if nextCalled {
		t.Fatal("handler protegido nao deveria ter sido executado")
	}
}

func TestMasterKeyMiddlewareAllowsValidKey(t *testing.T) {
	app := &App{MasterKey: "master-segura"}
	nextCalled := false
	next := http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		nextCalled = true
		w.WriteHeader(http.StatusNoContent)
	})
	recorder := httptest.NewRecorder()
	request := httptest.NewRequest(http.MethodPost, "/admin/keys", nil)
	request.Header.Set("Authorization", "Bearer master-segura")

	app.masterKeyAuthMiddleware(next).ServeHTTP(recorder, request)

	if !nextCalled || recorder.Code != http.StatusNoContent {
		t.Fatalf("chave valida deveria liberar o handler; status=%d", recorder.Code)
	}
}

func TestAPIKeyGenerationAndHash(t *testing.T) {
	key, err := generateAPIKey()
	if err != nil {
		t.Fatalf("erro ao gerar chave: %v", err)
	}
	if !strings.HasPrefix(key, "tm_key_") {
		t.Fatalf("prefixo inesperado: %s", key)
	}
	if len(hashAPIKey(key)) != 64 {
		t.Fatalf("hash SHA-256 deveria ter 64 caracteres")
	}
	firstHash := hashAPIKey(key)
	secondHash := hashAPIKey(key)
	if firstHash != secondHash {
		t.Fatal("hash deve ser deterministico")
	}
}
