FROM mcr.microsoft.com/dotnet/sdk:10.0 AS build
WORKDIR /app

# Set DOTNET_ROOT
ENV DOTNET_ROOT=/usr/share/dotnet
ENV PATH=/usr/share/dotnet:$PATH

# Copy solution files and central package versions
COPY Directory.Packages.props .

# Copy all project files needed for restore
COPY src/Ordering.API/Ordering.API.csproj src/Ordering.API/
COPY src/Ordering.Domain/Ordering.Domain.csproj src/Ordering.Domain/
COPY src/Ordering.Infrastructure/Ordering.Infrastructure.csproj src/Ordering.Infrastructure/
COPY src/EventBusRabbitMQ/EventBusRabbitMQ.csproj src/EventBusRabbitMQ/
COPY src/IntegrationEventLogEF/IntegrationEventLogEF.csproj src/IntegrationEventLogEF/
COPY src/eShop.ServiceDefaults/eShop.ServiceDefaults.csproj src/eShop.ServiceDefaults/
COPY src/EventBus/EventBus.csproj src/EventBus/
COPY src/Shared/ src/Shared/

# Restore dependencies
RUN dotnet restore src/Ordering.API/Ordering.API.csproj

# Copy everything
COPY . .

# Publish Ordering.API
RUN dotnet publish ./src/Ordering.API/Ordering.API.csproj \
    -c Release \
    -o /app/publish \
    /p:UseAppHost=false

FROM mcr.microsoft.com/dotnet/aspnet:10.0
WORKDIR /app

# Set DOTNET_ROOT
ENV DOTNET_ROOT=/usr/share/dotnet
ENV PATH=/usr/share/dotnet:$PATH

COPY --from=build /app/publish .

EXPOSE 80
ENV ASPNETCORE_URLS=http://+:80
ENV ASPNETCORE_ENVIRONMENT=Production

ENTRYPOINT ["dotnet", "Ordering.API.dll"]

