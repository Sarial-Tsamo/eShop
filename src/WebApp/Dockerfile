###############
# Build stage
###############

FROM mcr.microsoft.com/dotnet/sdk:10.0 AS build
WORKDIR /app

# Set DOTNET_ROOT
ENV DOTNET_ROOT=/usr/share/dotnet
ENV PATH=/usr/share/dotnet:$PATH

# Copy solution files and central package versions
COPY Directory.Packages.props .

# Copy all project files needed for restore
COPY src/WebApp/WebApp.csproj src/WebApp/
COPY src/eShop.ServiceDefaults/eShop.ServiceDefaults.csproj src/eShop.ServiceDefaults/
COPY src/Shared/ src/Shared/

# Restore dependencies
RUN dotnet restore src/WebApp/WebApp.csproj

# Copy everything
COPY . .

# Publish WebApp
RUN dotnet publish ./src/WebApp/WebApp.csproj \
    -c Release \
    -o /app/publish \
    /p:UseAppHost=false

###############
# Runtime stage
###############

FROM mcr.microsoft.com/dotnet/aspnet:10.0
WORKDIR /app

# Set DOTNET_ROOT
ENV DOTNET_ROOT=/usr/share/dotnet
ENV PATH=/usr/share/dotnet:$PATH

COPY --from=build /app/publish .

EXPOSE 80

ENV ASPNETCORE_URLS=http://+:80
ENV ASPNETCORE_ENVIRONMENT=Production

ENTRYPOINT ["dotnet", "WebApp.dll"]
