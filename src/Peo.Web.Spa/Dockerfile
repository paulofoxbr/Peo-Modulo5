# Build the Blazor WebAssembly app
FROM mcr.microsoft.com/dotnet/sdk:9.0 AS build
ARG BUILD_CONFIGURATION=Release
WORKDIR /src
COPY ["src/Peo.Web.Spa/Peo.Web.Spa.csproj", "src/Peo.Web.Spa/"]
RUN dotnet restore "./src/Peo.Web.Spa/Peo.Web.Spa.csproj"
COPY . .
WORKDIR "/src/src/Peo.Web.Spa"
RUN dotnet publish "./Peo.Web.Spa.csproj" -c $BUILD_CONFIGURATION -o /app/publish /p:UseAppHost=false

# Serve the static site via nginx
FROM nginx:alpine AS final
WORKDIR /usr/share/nginx/html
COPY --from=build /app/publish/wwwroot ./
COPY src/Peo.Web.Spa/nginx.conf /etc/nginx/conf.d/default.conf
EXPOSE 8080
