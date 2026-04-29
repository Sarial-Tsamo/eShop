FROM mcr.microsoft.com/dotnet/sdk:10.0 AS build
WORKDIR /app

# Set DOTNET_ROOT
ENV DOTNET_ROOT=/usr/share/dotnet
ENV PATH=/usr/share/dotnet:$PATH

# Set NuGet timeout to 5 minutes
ENV NUGET_TIMEOUT=300

# Copy solution files and central package versions
# Copy solution files and central package versions
COPY Directory.Packages.props .
COPY Directory.Build.props .
COPY Directory.Build.targets .
COPY global.json .
COPY nuget.config .


# Copy all project files needed for restore
COPY src/OrderProcessor/OrderProcessor.csproj src/OrderProcessor/
COPY src/EventBusRabbitMQ/EventBusRabbitMQ.csproj src/EventBusRabbitMQ/
COPY src/eShop.ServiceDefaults/eShop.ServiceDefaults.csproj src/eShop.ServiceDefaults/
COPY src/EventBus/EventBus.csproj src/EventBus/
COPY src/Shared/ src/Shared/

# Restore dependencies
RUN for i in {1..3}; do dotnet restore src/OrderProcessor/OrderProcessor.csproj --disable-parallel && break || sleep 30; done

# Copy everything
COPY . .

# Publish OrderProcessor
RUN dotnet publish ./src/OrderProcessor/OrderProcessor.csproj \
    -c Release \
    -o /app/publish \
    /p:UseAppHost=false

FROM mcr.microsoft.com/dotnet/runtime:10.0
WORKDIR /app

# Set DOTNET_ROOT
ENV DOTNET_ROOT=/usr/share/dotnet
ENV PATH=/usr/share/dotnet:$PATH

COPY --from=build /app/publish .

ENTRYPOINT [ "dotnet", "OrderProcessor.dll" ]

