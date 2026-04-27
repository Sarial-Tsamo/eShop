FROM mcr.microsoft.com/dotnet/sdk:9.0 AS build
WORKDIR /src

# Copy central package versions
COPY Directory.Packages.props ./

# Copy Basket.API project
COPY src/Basket.API/Basket.API.csproj ./src/Basket.API/

# Restore dependencies
RUN dotnet restore ./src/Basket.API/Basket.API.csproj

# Copy everything
COPY . .

# Publish Basket.API
RUN dotnet publish ./src/Basket.API/Basket.API.csproj \
    -c Release \
    -o /app/publish \
    /p:UseAppHost=false

FROM mcr.microsoft.com/dotnet/aspnet:9.0
WORKDIR /app

COPY --from=build /app/publish .
EXPOSE 80
ENV ASPNETCORE_URLS=http://+80
ENV ASPNETCORE_ENVIRONMENT=Production

ENTRYPOINT [ "dotnet", "Basket.API.dll" ]

