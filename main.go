package main

import (
	"log"
	"net/http"
	"os"
	"strings"

	"github.com/labstack/echo/v5"
	"github.com/pocketbase/pocketbase"
	"github.com/pocketbase/pocketbase/apis"
	"github.com/pocketbase/pocketbase/core"
)

func main() {
	app := pocketbase.New()

	// Get the API key from the environment variable
	apiKey := os.Getenv("POCKETBASE_API_KEY")
	if apiKey == "" {
		log.Fatal("POCKETBASE_API_KEY environment variable is not set")
	}

	// Add middleware to check for API key
	app.OnBeforeServe().Add(func(e *core.ServeEvent) error {
		e.Router.Use(func(next echo.HandlerFunc) echo.HandlerFunc {
			return func(c echo.Context) error {
				path := c.Request().URL.Path
				referer := c.Request().Referer()

				// Check if the request is for the API and not from the admin UI
				if strings.HasPrefix(path, "/api/") && !strings.Contains(referer, "/_/") {
					// Check for API key in header
					if c.Request().Header.Get("X-API-Key") != apiKey {
						return c.String(http.StatusUnauthorized, "Unauthorized")
					}
				}

				return next(c)
			}
		})

		// Serve static files
		e.Router.GET("/*", apis.StaticDirectoryHandler(os.DirFS("./pb_public"), false))
		return nil
	})

	if err := app.Start(); err != nil {
		log.Fatal(err)
	}
}